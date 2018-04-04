class Obsession < ApplicationRecord
  belongs_to :user # obsessions table has user_id foreign key column
  has_many :obsession_themes
  has_many :themes, through: :obsession_themes, dependent: :destroy
  has_many :plans, dependent: :destroy

  validates :time_consumed, presence: true, inclusion: { in: 0..24 }
  validates :anxiety_rating, presence: true, inclusion: { in: 1..10 }
end
