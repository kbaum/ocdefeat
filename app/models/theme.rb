class Theme < ApplicationRecord
  belongs_to :user # theme belongs to therapist user instance who created it
  has_many :obsessions
  validates :name, presence: true, uniqueness: true

  def prevalence_in_patients # instance method returns number of unique users who have at least 1 obsession w/ theme content
    User.obsessing_about(self).count
  end

  def obsessions_per_theme
    obsessions.count
  end
end
