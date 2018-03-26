class Obsession < ApplicationRecord
  belongs_to :user
  has_many :plans
  has_many :obsession_categories
  has_many :categories, through: :obsession_categories
end
