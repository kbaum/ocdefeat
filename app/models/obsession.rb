class Obsession < ApplicationRecord
  normalize_attribute :symptoms  # strips leading & trailing whitespace & sets symptoms attribute to nil if blank
  extend Datable

  scope :defeatable_by_flooding, -> { joins(:plans).merge(Plan.flooding).distinct }
  scope :defeatable_by_graded_exposure, -> { joins(:plans).merge(Plan.graded_exposure).distinct }
  scope :sans_plans, -> { where.not(id: Plan.all.map {|plan| plan.obsession_id}) }
  scope :presenting_symptoms, -> { where.not(symptoms: nil) }
  scope :symptomless, -> { where(symptoms: ["", " "]) }

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
  before_validation :hypotheticalize, on: [ :create, :update ]

  def self.by_anxiety_rating(anxiety_rating)
    where(anxiety_rating: anxiety_rating)
  end

  def self.least_to_most_distressing
    order(:anxiety_rating)
  end

  def self.most_to_least_distressing
    order(anxiety_rating: :desc)
  end

  def self.least_to_most_time_consuming
    order(:time_consumed)
  end

  def self.most_to_least_time_consuming
    order(time_consumed: :desc)
  end

  def self.by_theme(theme_id)
    where(id: Theme.find(theme_id).obsessions)
  end

  def self.by_patient(patient)
    where(user: patient)
  end

  def self.search_thoughts(search)
    if search
      where('intrusive_thought LIKE ?', "%#{search}%")
    else
      all
    end
  end

  def self.average_anxiety_rating # Find the average anxiety_rating for all obsessions
    average(:anxiety_rating)
  end

  private
    def hypotheticalize # sets intrusive_thought attribute of obsession = to formatted string "What if I...?"
      if !self.intrusive_thought.blank?
        idea = self.intrusive_thought.downcase.split(/\A\bwhat\b\s+\bif\b\s+\bi\b\s+/).join("").split("?").join("")
        self.intrusive_thought = "What if I " << "#{idea}?"
      end
    end
end
