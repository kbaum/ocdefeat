class Treatment < ApplicationRecord
  has_many :user_treatments, dependent: :destroy
  has_many :users, through: :user_treatments
  validates :treatment_type, uniqueness: true
end
