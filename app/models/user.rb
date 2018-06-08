class User < ApplicationRecord
  scope :unassigned_users, -> { where(role: 0) }
  scope :admins, -> { where(role: 3) }
  scope :therapists, -> { where(role: 2) }
  scope :patients, -> { where(role: 1) }
  scope :patients_very_unnerved, -> { patients.where(_exists(Obsession.where("obsessions.user_id = users.id").very_unnerving)) }
  scope :patients_obsessing, -> { patients.joins(:obsessions).distinct }
  scope :patients_planning, -> { patients.joins(:plans).distinct }

  enum role: { unassigned: 0, patient: 1, therapist: 2, admin: 3 }

  has_many :obsessions, dependent: :destroy
  has_many :plans, through: :obsessions, dependent: :destroy
  has_many :comments

  validates :name, presence: true
  validates :email, presence: true, email: true, uniqueness: true, length: { maximum: 100 }
  validates :variant, presence: true, variant: true
  validates :severity, presence: true, severity: true
  validates :role_requested, inclusion: { in: ["Patient", "Therapist", "Admin"], message: "must be selected from the available roles" }, on: :create

  has_secure_password
  #validates :password, presence: true, length: { minimum: 8 }, allow_nil: true
  # when a user edits their user information, they don't have to retype their password
  def self.find_or_create_by_omniauth(auth_hash)
    self.where(provider: auth_hash["provider"], uid: auth_hash["uid"]).first_or_create do |user|
      user.name = auth_hash["info"]["name"] # "Jenna Leopold"
      user.email = auth_hash["info"]["email"] # "jleopold424@gmail.com"
      user.password = SecureRandom.hex # a random, unique string
      user.role_requested = "Patient"
      user.severity = "Mild"
      user.variant = "Traditional"
      # we can't add a default role_requested value of "patient" in users table because
      # our admin and therapists don't want to be patients (see seed data)
      # If a brand new user signs on via Twitter (user cannot be found in the DB),
      # by default, just set their role_requested to "patient" and their OCD severity to "mild"
      # as these can be edited, and the majority of app users will presumably be patients
    end
  end

  def self.symptomatic # returns AR::Relation of users who have at least 1 obsession whose symptoms attribute != blank string
    patients_obsessing.merge(Obsession.presenting_symptoms)
  end

  def self.asymptomatic # returns AR::Relation of users whose obsessions ALL have symptoms attribute = blank string
    patients_obsessing.where(_not_exists(Obsession.where("obsessions.user_id = users.id").presenting_symptoms))
  end

  def self.ruminating_yesterday # returns AR::Relation of users who created obsessions yesterday
    interval = (Time.now.midnight - 1.day)..Time.now.midnight
    patients_obsessing.where(obsessions: { created_at: interval })
  end

  def self.ruminating_today # returns AR::Relation of users who created obsessions today
    interval = Time.now.midnight..Time.now
    patients_obsessing.where(obsessions: { created_at: interval })
  end

  def self.unexposed_to_obsession # Returns all users who have at least 1 obsession for which no ERP plans were designed
    patients_obsessing.merge(Obsession.sans_plans)
  end

  def self.by_role(the_role)
    where(role: the_role)
  end

  def self.awaiting_assignment(rejected_roles, role_number)
    where.not(role_requested: rejected_roles, role: role_number)
  end

  def self.by_ocd_severity(severity)
    where(severity: severity)
  end

  def self.by_ocd_variant(variant)
    where(variant: variant)
  end

  def self.by_severity_and_variant(severity, variant)
    by_ocd_severity(severity).by_ocd_variant(variant)
  end

  def obsession_count
    obsessions.count
  end

  def self.least_to_most_obsessions
    patients.sort_by(&:obsession_count) # equivalent to: patients.sort_by {|patient| patient.obsession_count}
  end

  def self.most_to_least_obsessions
    patients.sort {|a,b| b.obsession_count <=> a.obsession_count}
  end

  def self.patients_planning_preliminarily # returns AR::Relation of users who have at least 1 plan that lacks steps
    patients_planning.merge(Plan.stepless)
  end

  def self.patients_with_populated_plan # returns AR::Relation of users who have at least 1 plan populated with steps
    patients_planning.merge(Plan.procedural)
  end

  def self.patients_with_unfinished_plan # returns array of users who have at least 1 plan that is unfinished
    patients_with_populated_plan.select {|user| user.plans.any? {|plan| !plan.done?}}
  end

  def self.patients_fully_desensitized # returns array of users who have obsessions, whose obsessions do NOT lack ERP plans, and whose ERP plans are all completed
    obsessing = User.patients_obsessing
    obsessing_but_fully_planning = obsessing.reject {|user| obsessing.with_obsession_without_plan.include?(user)}
    obsessing_but_fully_planning_with_steps = obsessing_but_fully_planning.reject {|user| user.plans.any? {|plan| plan.steps.empty?}}
    obsessing_but_fully_planning_with_steps.select {|user| user.plans.all? {|plan| plan.done?}}
  end

  def num_plans_designed
    self.plans.count if self.patient?
  end

  def num_plans_completed
    self.plans.select {|plan| plan.done?}.count if self.patient?
  end

  def self.sort_by_ascending_plan_count
    self.patients.sort_by {|patient| patient.num_plans_designed}
  end

  def self.sort_by_descending_plan_count
    self.sort_by_ascending_plan_count.reverse
  end

  def self.num_users_obsessing_about(theme_id)
    self.patients.select {|p| p.obsessions.any? {|o| o.theme_ids.include?(theme_id)}}.count
  end

  def self._exists(scope)
    "EXISTS(#{scope.to_sql})"
  end

  def self._not_exists(scope)
    "NOT #{_exists(scope)}"
  end
  # rejected_roles is an array of string roles the user does NOT want to be and
  # role_number is the requested role's integer value
  # so if we're looking for all unassigned_users who want to be patients, we call
  # User.awaiting_assignment(["Therapist", "Admin"], 1)
  # we're looking for user instances who are NOT already patients (with role = 1)
  # AND who did NOT request the roles of therapist or admin
  # Rails documentation favors .where.not instead of !=, but above method is same as saying:
  #def self.awaiting_assignment(role_requested, role_number)
   #self.where("role_requested = ? AND role != ?", role_requested, role_number)
  #end
end

# Explanation of #find_or_create_by_omniauth(auth_hash):
# Trying to find user instance by their provider attribute ("Twitter") and their user ID (uid) on Twitter
# If such a user exists in the DB already, return that user instance
# If a user instance does NOT exist with that UID from Twitter, then create one:
# The newly instantiated user instance that was just created is passed to the block,
# and we set its name attribute value = the name provided by Twitter -- auth_hash["info"]["name"],
# we set its twitter_handle = auth_hash["info"]["nickname"],
# we set its bio attribute = auth_hash["info"]["description"]
# and we give it a random, unique string password using SecureRandom.hex
# The user instance is returned at end of method call
