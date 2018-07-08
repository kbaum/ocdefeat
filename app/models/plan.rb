class Plan < ApplicationRecord
  extend Datable

  scope :flooding, -> { where(flooded: true) }
  scope :graded_exposure, -> { where.not(flooded: true) }
  scope :accomplished, -> { where(finished: true) }
  scope :unaccomplished, -> { where.not(finished: true) }
  scope :with_steps, -> { joins(:steps).distinct }
  scope :stepless, -> { where.not("exists ( #{Step.where('plans.id = steps.plan_id').select(1).to_sql} )") }

  belongs_to :obsession
  delegate :user, to: :obsession # I can call #user on plan instance to return user instance to which the plan belongs. I don't use allow_nil: true b/c a plan belongs to an obsession and not having an obsession is an error condition
  has_many :steps, dependent: :destroy

  validates :title, presence: true, uniqueness: true
  validates :goal, presence: true
  validates :finished, finished: true, on: :update

  def self.with_incomplete_step # Returns AR::Relation of plans with steps where at least 1 step in each plan is incomplete
    with_steps.merge(Step.incomplete)
  end

  def self.unfinished_but_with_all_steps_completed
    with_steps.where.not(id: Step.incomplete.map {|step| step.plan})
  end

  def without_step_or_with_incomplete_step?
    steps.empty? || steps.detect {|step| !step.completed?}
  end

  def self.designed_by(designer_id)
    User.patients.find(designer_id).plans
  end

  def self.by_theme(theme_id)
    where(obsession: Theme.find(theme_id).obsessions)
  end
end
