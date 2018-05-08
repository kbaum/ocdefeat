class Plan < ApplicationRecord
  scope :stepless, -> { includes(:steps).where(steps: { id: nil }) } # returns AR::Relation of all plans that have no steps (i.e.'array' of preliminary plans)

  belongs_to :obsession
  has_many :steps

  validates :title, presence: true, uniqueness: true
  validates :goal, presence: true

  def designer
    self.obsession.user
  end

  def done? # returns true if plan consists of at least 1 step and all steps are completed (step's status = 1)
    self.steps.count > 0 && self.steps.all? {|step| step.complete?}
  end

  def self.by_obsession(the_obsession_id)
    self.where(obsession_id: the_obsession_id)
  end

  def self.by_title(the_title)
    self.find_by(title: the_title)
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
