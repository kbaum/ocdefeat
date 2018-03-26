class Obsession < ApplicationRecord
  belongs_to :user
  has_many :plans
  has_many :obsession_themes
  has_many :themes, through: :obsession_themes
end
