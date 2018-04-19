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

  def self.by_theme(theme_id)
    where("id IN (?)", Theme.find(theme_id).obsession_ids)
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
end
