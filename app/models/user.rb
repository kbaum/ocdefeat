class User < ApplicationRecord
  scope :therapists, -> { where(role: 2) }
  scope :patients, -> { where(role: 1) }
  scope :patients_overanxious, -> { patients.joins(:obsessions).where("obsessions.anxiety_rating > ?", Obsession.average_anxiety_rating).distinct }
  scope :patients_uncounseled, -> { patients.where(counselor_id: nil) }
  scope :patients_obsessing, -> { patients.joins(:obsessions).distinct }
  scope :patients_planning, -> { patients.joins(:plans).distinct }
  scope :patients_nonobsessive, -> { patients.where.not(id: Obsession.all.map {|obsession| obsession.user_id}) }
  scope :patients_obsessive_but_symptomless, -> { patients.joins(:obsessions).where.not(id: Obsession.presenting_symptoms.map {|o| o.user_id}).distinct }

  enum role: { unassigned: 0, patient: 1, therapist: 2, admin: 3 }

  has_many :counselees, class_name: "User", foreign_key: "counselor_id"
  belongs_to :counselor, class_name: "User", optional: true

  has_many :obsessions, dependent: :destroy
  has_many :plans, through: :obsessions, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :user_treatments, dependent: :destroy
  has_many :treatments, through: :user_treatments

  validates :name, presence: true
  validates :email, presence: true, email: true, uniqueness: true, length: { maximum: 100 }
  validates :variant, presence: true, variant: true
  validates :severity, presence: true, severity: true
  validates :role_requested, inclusion: { in: ["Patient", "Therapist", "Admin"], message: "must be selected from the available roles" }, on: :create
  has_secure_password
  validates :password, length: { minimum: 8 }, allow_nil: true # when a user edits their user information, they don't have to retype their password
  validates_associated :treatments

  def self.find_or_create_by_omniauth(auth_hash)
    self.where(provider: auth_hash["provider"], uid: auth_hash["uid"]).first_or_create do |user|
      user.name = auth_hash["info"]["name"] # "Jenna Leopold"
      user.email = auth_hash["info"]["email"] # "jleopold424@gmail.com"
      user.password = SecureRandom.hex # a random, unique string
      user.role_requested = "Patient"
      user.severity = "Mild"
      user.variant = "Traditional"
    end
  end

  def treatments_attributes=(treatments_attributes)
    treatments_attributes.values.each do |treatments_attribute|
      if !treatments_attribute["user_treatments"]["treatment_id"].blank? # User selects an existing treatment from the dropdown menu
        existing_treatment = Treatment.find(treatments_attribute["user_treatments"]["treatment_id"])
        self.user_treatments.build(user: self, treatment: existing_treatment, efficacy: treatments_attribute["user_treatments"]["efficacy"], duration: treatments_attribute["user_treatments"]["duration"])
      elsif !treatments_attribute["treatment_type"].blank? # User typed a treatment into the form field
        treatment = Treatment.find_or_create_by(treatment_type: treatments_attribute["treatment_type"])
        self.user_treatments.build(user: self, treatment: treatment, efficacy: treatments_attribute["user_treatments"]["efficacy"], duration: treatments_attribute["user_treatments"]["duration"])
      end
    end
  end

  def self.obsessing_about(theme)
    patients.joins(obsessions: :theme).where(themes: { id: theme } ).distinct
  end

  def self.count_counselees # returns a hash. keys = string name counselor, values = number of counselees assigned to that counselor
    therapists.left_outer_joins(:counselees).group("users.name").count("counselees_users.id")
  end

  def self.symptomatic # returns AR::Relation of users who have at least 1 obsession whose symptoms attribute != blank string
    patients_obsessing.merge(Obsession.presenting_symptoms)
  end

  def self.ruminating_yesterday # returns AR::Relation of users who created obsessions yesterday
    interval = (Time.now.midnight - 1.day)..Time.now.midnight
    patients_obsessing.where(obsessions: { created_at: interval })
  end

  def self.ruminating_today # returns AR::Relation of users who created obsessions today
    interval = Time.now.midnight..Time.now
    patients_obsessing.where(obsessions: { created_at: interval })
  end

  def self.unexposed_to_obsession # Returns AR::Relation of users who have at least 1 obsession for which no ERP plans were designed
    patients_obsessing.merge(Obsession.sans_plans)
  end

  def self.patients_planning_or_practicing_erp
    patients_planning.merge(Plan.unaccomplished)
  end

  def self.with_finished_plan # Returns AR::Relation of users who designed at least 1 plan that was marked as finished
    patients_planning.merge(Plan.accomplished)
  end

  def self.by_role(string_role)
    where(role: string_role)
  end

  def self.awaiting_assignment(rejected_roles, role_number)
    by_role("unassigned").where.not(role_requested: rejected_roles, role: role_number)
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

  def plan_count
    plans.count
  end

  def self.patients_planning_preliminarily # returns AR::Relation of users who have at least 1 plan that lacks steps
    patients_planning.merge(Plan.stepless)
  end
end

# rejected_roles is an array of string roles the user does NOT want to be and
# role_number is the requested role's integer value
# so if we're looking for all unassigned users who want to be patients, we call
# User.awaiting_assignment(["Therapist", "Admin"], 1)
# we're looking for user instances who are NOT already patients (with role = 1)
# AND who did NOT request the roles of therapist or admin


# Explanation of #find_or_create_by_omniauth(auth_hash):
# Trying to find user instance by their provider attribute ("twitter") and their user ID (uid) on Twitter
# If such a user exists in the DB already, return that user instance
# If a user instance does NOT exist with that uid from Twitter, then create one:
# The newly instantiated user instance that was just created is passed to the block,
# we set its name attribute value = the name provided by Twitter -- auth_hash["info"]["name"],
# and we give it a random, unique string password using SecureRandom.hex
# The user instance is returned at end of method call
