class Plan < ApplicationRecord
  scope :flooding, -> { where(flooded: true) }
  scope :graded_exposure, -> { where.not(flooded: true) }
  scope :accomplished, -> { where(progress: 1) }
  scope :unaccomplished, -> { where(progress: 0) }
  scope :with_steps, -> { joins(:steps).where.not(steps: { id: nil }).distinct }
  scope :stepless, -> { where.not(id: Step.all.map {|step| step.plan_id}) }

  PLAN_PROGRESS = {
    :unfinished => 0,
    :finished => 1
  }

  belongs_to :obsession
  delegate :user, to: :obsession # I can call #user on plan instance to return user instance to which the plan belongs. I don't use allow_nil: true b/c a plan belongs to an obsession and not having an obsession is an error condition
  has_many :steps, dependent: :destroy

  validates :title, presence: true, uniqueness: true
  validates :goal, presence: true
  validates :flooded, inclusion: { in: [true, false] }
  validates :progress, progress: true, on: :update

  def unfinished? # an unfinished plan (self) has a progress attribute value = 0
    self.progress == PLAN_PROGRESS[:unfinished]
  end

  def finished? # a finished plan (self) has a progress attribute value = 1
    self.progress == PLAN_PROGRESS[:finished]
  end

  def unachieved?
    steps.empty? || steps.detect {|step| step.incomplete?}
  end

  #def self.delineated_but_unaccomplished
    #with_steps.unaccomplished
  #end

  def self.designed_by(designer_id)
    User.patients.find(designer_id).plans
  end

  def self.by_subset(subset_id)
    where(obsession_id: Theme.find(subset_id).obsession_ids)
  end

  def self.from_today
    where("created_at >=?", Time.zone.today.beginning_of_day)
  end

  def self.past_plans
    where("created_at <?", Time.zone.today.beginning_of_day)
  end
end
