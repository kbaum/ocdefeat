class Obsession < ApplicationRecord
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
# The following 4 class methods are used when a patient filters their own obsessions on the obsessions index page
  def self.by_theme(theme_id)
    where("id IN (?)", Theme.find(theme_id).obsession_ids)
  end

  def self.by_anxiety_amount(anxiety_amount)
    where(anxiety_rating: anxiety_amount)
  end

  def self.least_to_most_distressing
    self.order(:anxiety_rating)
  end

  def self.most_to_least_distressing
    self.order(anxiety_rating: :desc)
  end

  def self.least_to_most_time_consuming
    self.order(:time_consumed)
  end

  def self.most_to_least_time_consuming
    self.order(time_consumed: :desc)
  end

  def self.most_time_consuming_by_user(user_id)
    user_obsessions = User.where(role: 1).find_by(id: user_id).obsessions
    if user_obsessions.empty? # if the requested user has NO obsessions
      nil # the class method returns nil
    else # if the requested user has obsessions
      user_obsessions.order(time_consumed: :desc).first # class method returns obsession instance (belonging to user) that has the highest time_consumed value
    end
  end

  def self.by_patient(user_id)
    self.where(user_id: user_id)
  end

  def self.from_today
    self.where("created_at >=?", Time.zone.today.beginning_of_day)
  end

  def self.old_obsessions
    self.where("created_at <?", Time.zone.today.beginning_of_day)
  end

  def self.most_distressing_by_user(user_id)
    user_obsessions = User.where(role: 1).find_by(id: user_id).obsessions # user_obsessions stores 'array' of all obsessions belonging to a specific patient

    if user_obsessions.empty? # If the user has no obsessions, method returns nil
      nil
    else # The user has obsessions
      max_anxiety = user_obsessions.order(anxiety_rating: :desc).map {|o| o.anxiety_rating}.first
      user_obsessions.where(anxiety_rating: max_anxiety) # method returns 'array' of all the patient's obsessions rated at the patient's highest anxiety level
    end
  end

  def plans_per_obsession
    self.plans.count
  end

  def self.sans_plans
    self.find_each.reject {|o| o.plans_per_obsession > 0}
  end

  def self.least_to_most_plans
    self.all.sort_by {|o| o.plans_per_obsession}
  end

  def self.most_to_least_plans
    self.least_to_most_plans.reverse
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
