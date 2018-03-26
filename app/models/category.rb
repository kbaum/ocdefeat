class Category < ApplicationRecord
  has_many :obsession_categories
  has_many :obsessions, through: :obsession_categories
end
