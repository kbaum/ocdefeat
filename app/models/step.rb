class Step < ApplicationRecord
  scope :not_performed, -> { where(status: 0) }

  belongs_to :plan

  validates :instructions, presence: true
  validates :duration, presence: true
  validates :discomfort_degree, inclusion: { in: 1..10 }, on: :update, allow_blank: true
  validates :completed, completed: true, on: :update
end
