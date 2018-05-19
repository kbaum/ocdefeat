class Plan < ApplicationRecord
  scope :procedural, -> { includes(:steps).where.not(steps: { id: nil }) }
  scope :stepless, -> { includes(:steps).where(steps: { id: nil }) } # returns AR::Relation of all plans that have no steps (i.e.'array' of preliminary plans)

  belongs_to :obsession
  has_many :steps, dependent: :destroy

  validates :title, presence: true, uniqueness: true
  validates :goal, presence: true

  def done?
    steps.count > 0 && steps.all? {|step| step.complete?} # instance method returns true if plan consists of at least 1 step and all steps are completed (each step's status = 1)
  end

  def designer # instance method called on plan instance (implicit self) returns user who designed the plan
    obsession.user
  end

  def self.designed_by(designer_id)
    User.patients.find(designer_id).plans
  end

  def self.by_subset(subset_id)
    where(obsession_id: Theme.find(subset_id).obsession_ids)
  end

  def self.finished # class method returns AR::Relation of finished plans. A plan is finished if it contains at least 1 step and all steps have status = 1
    procedural.merge(Step.performed)
  end

  def self.unfinished # class method returns AR::Relation of unfinished plans. A plan is unfinished if it contains at least 1 step w/ status = 0
    procedural.merge(Step.not_performed)
  end

  def self.from_today
    where("created_at >=?", Time.zone.today.beginning_of_day)
  end

  def self.past_plans
    where("created_at <?", Time.zone.today.beginning_of_day)
  end
end
