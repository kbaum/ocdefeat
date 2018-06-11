class Theme < ApplicationRecord
  validates :name, presence: true, uniqueness: true

  def prevalence_in_patients # instance method returns number of unique users who have at least 1 obsession w/ theme content
    self.obsessions.map {|o| o.user}.uniq.count
  end

  def self.least_to_most_prevalent # class method returns array of theme instances ordered by those w/ the least to greatest number of unique users having obsessions about these themes
    self.all.sort_by {|theme| theme.prevalence_in_patients}
  end

  def self.most_to_least_prevalent # class method returns array of theme instances ordered by those w/ the greatest to least number of unique users having obsessions about these themes
    self.all.sort {|a,b| b.prevalence_in_patients <=> a.prevalence_in_patients}
  end

  def obsessions_per_theme # instance method called on theme instance returns the number of obsessions classified in theme
    self.obsessions.count
  end

  def self.least_to_most_obsessions # class method returns array of theme instances ordered by those with the least to most obsessions classified in them
    self.all.sort_by {|theme| theme.obsessions_per_theme}
  end

  def self.most_to_least_obsessions # class method returns array of theme instances ordered by those with the most to least obsessions classified in them
    self.all.sort {|a,b| b.obsessions_per_theme <=> a.obsessions_per_theme}
  end
end
