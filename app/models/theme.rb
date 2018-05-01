class Theme < ApplicationRecord
  has_many :obsession_themes
  has_many :obsessions, through: :obsession_themes
  validates :name, uniqueness: true

  def prevalence_in_patients # instance method returns number of users who have at least 1 obsession w/ theme content
    self.obsessions.map {|o| o.user}.uniq.count
  end
end
