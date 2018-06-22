class Treatment < ApplicationRecord
  has_many :user_treatments
  has_many :users, through: :user_treatments

  validates :treatment_type, presence: true
end
