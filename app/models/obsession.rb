class Obsession < ApplicationRecord
  scope :most_unnerving, -> { order(anxiety_rating: :desc).first }
  scope :most_pervasive, -> { order(time_consumed: :desc).first }

  belongs_to :user # obsessions table has user_id foreign key column
  has_many :obsession_themes
  has_many :themes, through: :obsession_themes, dependent: :destroy
  has_many :plans, dependent: :destroy

  validates :intrusive_thought, presence: true, uniqueness: true
  validates :triggers, presence: true
  validates :time_consumed, presence: true, inclusion: { in: 0..24 }
  validates :anxiety_rating, presence: true, inclusion: { in: 1..10 }
  validates :rituals, presence: true

  accepts_nested_attributes_for :themes, reject_if: proc { |attributes| attributes['name'].blank? }
  # defines attribute writer method #themes_attributes= called on an obsession instance
  # obsession record will not be built for the attributes hash if name of theme is blank
  def themes_attributes=(themes_attributes)
    themes_attributes.values.each do |theme_attribute|
      if theme_attribute[:name].present?
        theme = Theme.find_or_create_by(theme_attribute)
        if !self.themes.include?(theme)
          self.obsession_themes.build(:theme => theme)
        end
      end
    end
  end

  def self.by_anxiety_amount(anxiety_amount) # anxiety_amount is an integer in the range 1-10
    where(anxiety_rating: anxiety_amount)
  end # returns ActiveRecord::Relation ('array') of obsessions w/ given anxiety_rating
  # or an empty 'array' #<ActiveRecord::Relation []> if no obsessions are found w/ that anxiety_rating
  def self.least_to_most_distressing
    order(:anxiety_rating)
  end

  def self.most_to_least_distressing
    order(anxiety_rating: :desc)
  end

  def self.by_theme(theme_id) # returns 'array' of obsessions classified in selected theme, or empty 'array' if none are found
    where("id IN (?)", Theme.find(theme_id).obsession_ids)
  end

  def self.least_to_most_time_consuming
    order(:time_consumed)
  end

  def self.most_to_least_time_consuming
    order(time_consumed: :desc)
  end

  def self.by_patient(patient_id)
    where(user_id: patient_id)
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

  def self.sans_plans
    all.select {|obsession| obsession.plans_per_obsession == 0}
  end

  def self.least_to_most_plans
    all.sort_by(&:plans_per_obsession) # self.all.sort_by {|o| o.plans_per_obsession}
  end

  def self.most_to_least_plans
    all.sort {|a,b| b.plans_per_obsession <=> a.plans_per_obsession}
  end

  def obsessify(thought) # instance method called on obsession instance takes string argument, sets intrusive_thought attribute of obsession to formatted string
    self.intrusive_thought = "What if I " << "#{thought}?"
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
