class Obsession < ApplicationRecord
  normalize_attribute :symptoms  # strips leading & trailing whitespace & sets symptoms attribute to nil if blank
  extend Datable

  scope :defeatable_by_flooding, -> { joins(:plans).merge(Plan.flooding).distinct }
  scope :defeatable_by_graded_exposure, -> { joins(:plans).merge(Plan.graded_exposure).distinct }
  scope :sans_plans, -> { where.not("exists ( #{Plan.where('obsessions.id = plans.obsession_id').select(1).to_sql} )") }
  scope :presenting_symptoms, -> { where.not(symptoms: nil) }
  scope :symptomless, -> { where(symptoms: nil) }

  belongs_to :theme
  belongs_to :user
  delegate :name, to: :user, prefix: :patient # I can call #patient_name on obsession instance to return the name attribute value of user instance to which obsession belongs.
  has_many :plans, dependent: :destroy
  has_many :comments, dependent: :destroy

  validates :intrusive_thought, presence: true, uniqueness: true
  validates :triggers, presence: true
  validates :time_consumed, inclusion: { in: 0..24, message: "must be a valid timeframe within a 24-hour day" }
  validates :anxiety_rating, inclusion: { in: 1..10, message: "must be measured on a scale of 1-10" }
  validates :rituals, presence: true
  validates :theme_id, presence: true, on: :create # adds field_with_errors styling to select label

  def self.by_anxiety_rating(anxiety_rating)
    where(anxiety_rating: anxiety_rating)
  end

  def self.most_to_least_distressing
    order(anxiety_rating: :desc)
  end

  def self.most_to_least_time_consuming
    order(time_consumed: :desc)
  end

  def self.by_patient(patient)
    where(user: patient)
  end
end
