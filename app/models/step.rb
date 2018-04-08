class Step < ApplicationRecord
  STEP_STATUS = {
    :incomplete => 0,
    :complete => 1
  }

  belongs_to :plan

  def complete?
    self.status == STEP_STATUS[:complete]
  end

  def incomplete?
    self.status == STEP_STATUS[:incomplete]
  end
end
