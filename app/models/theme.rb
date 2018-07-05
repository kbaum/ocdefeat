class Theme < ApplicationRecord
  belongs_to :user # theme belongs to therapist user instance who created it
  has_many :obsessions
  validates :name, presence: true, uniqueness: true

  delegate :name, to: :user, prefix: "contributor" # I can call #contributor_name on theme instance to return the name of therapist user who created the theme

  def prevalence_in_patients # instance method returns number of unique users who have at least 1 obsession w/ theme content
    User.obsessing_about(self).count
  end

  def obsessions_per_theme
    obsessions.count
  end
end
