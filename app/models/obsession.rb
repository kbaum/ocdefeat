class Obsession < ApplicationRecord
  scope :defeatable_by_flooding, -> { joins(:plans).where(plans: { flooded: true }).distinct }
  scope :very_unnerving, -> { where("anxiety_rating > ?", 5) }
  scope :sans_plans, -> { includes(:plans).where(plans: { id: nil }) }
  scope :presenting_symptoms, -> { where.not(symptoms: ["", " "]) }
  scope :symptomless, -> { where(symptoms: ["", " "]) }

  belongs_to :theme
  belongs_to :user
  delegate :name, :variant, to: :user, prefix: :patient # I can call #patient_name on obsession instance to return the name attribute value of user instance to which obsession belongs. I can also call #patient_variant on obsession to return OCD variant of user to which obsession belongs
  has_many :plans, dependent: :destroy
  has_many :comments, dependent: :destroy

  validates :intrusive_thought, presence: true, uniqueness: true
  validates :triggers, presence: true
  validates :time_consumed, presence: true, inclusion: { in: 0..24 }
  validates :anxiety_rating, presence: true, inclusion: { in: 1..10 }
  validates :rituals, presence: true
  before_validation :hypotheticalize, on: [ :create, :update ]

  def self.by_anxiety_amount(anxiety_amount) # anxiety_amount is an integer in the range 1-10
    where(anxiety_rating: anxiety_amount)
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

  def self.by_theme(theme_id) # returns AR::Relation of obsessions classified in selected theme or empty AR::Relation if none are found
    where(id: Theme.find(theme_id).obsession_ids)
  end

  def self.by_patient(patient)
    where(user: patient)
  end

  def self.from_today
    where("created_at >=?", Time.zone.today.beginning_of_day)
  end

  def self.old_obsessions
    where("created_at <?", Time.zone.today.beginning_of_day)
  end

  def plans_per_obsession # instance method called on obsession instance.
    plans.count
  end

  def self.least_to_most_plans
    all.sort_by(&:plans_per_obsession) # self.all.sort_by {|o| o.plans_per_obsession}
  end

  def self.most_to_least_plans
    all.sort {|a,b| b.plans_per_obsession <=> a.plans_per_obsession}
  end

  def self.search_thoughts(search)
    if search
      where('intrusive_thought LIKE ?', "%#{search}%")
    else
      all
    end
  end

  private
    def hypotheticalize # sets intrusive_thought attribute of obsession = to formatted string "What if I...?"
      idea = self.intrusive_thought.downcase.split(/\A\bwhat\b\s+\bif\b\s+\bi\b\s+/).join("").split("?").join("")
      self.intrusive_thought = "What if I " << "#{idea}?"
    end
end
  # Explanation of #themes_attributes=(themes_attributes):
  # themes_attributes is a hash that looks like {"name" => "Contamination OCD"}
  # themes_attributes.values is the array ["Contamination OCD"]
  # If the user submitted a name of an OCD theme in the form (in this case "Contamination OCD"),
  # i.e. the name of the theme is present,
  # find and return the theme instance whose name attribute value = "Contamination OCD" if one exists,
  # but if such a theme does not exist, then create a theme instance with name = "Contamination OCD"
  # If the obsession instance (self) is not already classified within that OCD theme,
  # self.themes.include?(theme) returns false, and !false is true
  # There is a many-to-many relationship between obsessions and themes, because an obsession can
  # pertain to many OCD themes, and an OCD theme has many obsessions classified within it.
  # An obsession_theme instance of ObsessionTheme join models belongs to both an obsession and a theme
  # We're building an obsession_theme off of the obsession (self), so it already belongs to the obsession,
  # and then we set the theme attribute of the obsession_theme instance = the theme instance
