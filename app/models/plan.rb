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

  def designer # instance method called on plan instance (implicit self) returns user who designed the plan
    obsession.user
  end

  def self.designed_by(designer_id)
    User.patients.find(designer_id).plans
  end

  def self.by_subset(subset_id)
    where("obsession_id IN (?)", Theme.find(subset_id).obsession_ids)
  end

  def self.finished # class method returns AR::Relation of all plans (with at least 1 step) that are completed
    procedural.joins(:steps).distinct.where(steps: { status: 1 })
  end

  def self.unfinished # class method returns an array of titles of unfinished plans
    procedural.select {|plan| !plan.done?}.pluck(:title)
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
