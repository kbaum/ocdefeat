class Theme < ApplicationRecord
  has_many :obsession_themes
  has_many :obsessions, through: :obsession_themes
  validates :name, uniqueness: true

  def num_obsessions
    self.obsessions.count > 0 ? "This OCD theme currently contains #{pluralize(self.obsessions.count, 'obsession')}." :
    "No obsessions currently pertain to this OCD theme!"
  end
end
