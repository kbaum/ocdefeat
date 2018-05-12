class Plan < ApplicationRecord
  scope :procedural, -> { includes(:steps).where.not(steps: { id: nil }) }
  scope :stepless, -> { includes(:steps).where(steps: { id: nil }) } # returns AR::Relation of all plans that have no steps (i.e.'array' of preliminary plans)

  belongs_to :obsession
  has_many :steps, dependent: :destroy

  validates :title, presence: true, uniqueness: true
  validates :goal, presence: true

  def done?
    steps.count > 0 && steps.all? {|step| step.complete?} # instance method returns true if plan consists of at least 2 steps (repeated exposure) and all steps are completed (each step's status = 1)
  end

  def self.finished_by(user_id) # returns an array of string titles of plans completed by the selected patient
    User.patients.find(user_id).plans.select {|plan| plan.done?}.pluck(:title)
  end

  def self.unfinished_by(user_id) # returns an array of string titles of plans NOT yet completed by the selected patient
    User.patients.find(user_id).plans.reject {|plan| plan.done?}.pluck(:title)
  end

  def designer
    self.obsession.user
  end

  def self.by_obsession(the_obsession_id)
    self.where(obsession_id: the_obsession_id)
  end

  def self.by_theme(theme_id)
    self.where("obsession_id IN (?)", Theme.find(theme_id).obsession_ids)
  end

  def self.by_designer(designer_id)
    User.where(role: 1).find(designer_id).plans
  end

  def self.with_steps # class method returns all plan instances that have 1 or more steps
    self.all.select {|plan| plan.steps.count >= 1}
  end

  def self.completed # class method returns 'array' of all plans (with at least 1 step) that are completed
    self.with_steps.reject {|plan| !plan.done?}
  end

  def self.not_yet_completed # class method returns 'array' of all plans (with at least 1 step) that are not completed
    self.with_steps.reject {|plan| plan.done?}
  end

  def self.plans_completed_by_patient(patient_id) # returns 'array' of all completed plans designed by a particular patient
    User.where(role: 1).find(patient_id).plans.select {|plan| plan.done?}
  end

  def self.plans_pending_completion_by_patient(patient_id) # returns 'array' of all plans designed by a particular patient that are incomplete
    User.where(role: 1).find(patient_id).plans.reject {|plan| plan.done?}
  end

  def self.from_today
    where("created_at >=?", Time.zone.today.beginning_of_day)
  end

  def self.past_plans
    where("created_at <?", Time.zone.today.beginning_of_day)
  end
end
