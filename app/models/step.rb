class Step < ApplicationRecord
  STEP_STATUS = {
    :incomplete => 0,
    :complete => 1
  }
  
  belongs_to :plan
end
