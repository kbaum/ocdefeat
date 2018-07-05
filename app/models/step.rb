class Step < ApplicationRecord
  STEP_STATUS = {
    :incomplete => 0,
    :complete => 1
  }

  scope :not_performed, -> { where(status: 0) }

  belongs_to :plan

  validates :instructions, presence: true
  validates :duration, presence: true
  validates :discomfort_degree, inclusion: { in: 1..10 }, on: :update, allow_blank: true
  validates :status, status: true

  def complete? # a completed step (self) has a status attribute value = 1
    self.status == STEP_STATUS[:complete]
  end

  def incomplete? # an incomplete step (self) has a status attribute value = 0
    self.status == STEP_STATUS[:incomplete]
  end
end
