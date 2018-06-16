class Plan < ApplicationRecord
  scope :flooding, -> { where(flooded: true) }
  scope :graded_exposure, -> { where(flooded: false) }
  scope :procedural, -> { includes(:steps).where.not(steps: { id: nil }) }
  scope :stepless, -> { includes(:steps).where(steps: { id: nil }) } # returns AR::Relation of all plans that have no steps (i.e.'array' of preliminary plans)

  PLAN_PROGRESS = {
    :unaccomplished => 0,
    :accomplished => 1
  }

  belongs_to :obsession
  delegate :user, to: :obsession, allow_nil: true # I can call #user on plan instance to return user instance to which the plan belongs
  has_many :steps, dependent: :destroy

  validates :title, presence: true, uniqueness: true
  validates :goal, presence: true
  validates :progress, progress: true

  def unaccomplished? # an unaccomplished plan (self) has a progress attribute value = 0
    self.progress == PLAN_PROGRESS[:unaccomplished]
  end

  def accomplished? # an accomplished plan (self) has a progress attribute value = 1
    self.progress == PLAN_PROGRESS[:accomplished]
  end

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
