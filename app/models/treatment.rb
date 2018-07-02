class Treatment < ApplicationRecord
  #has_many :user_treatments, dependent: :destroy
  #has_many :users, through: :user_treatments
  has_many :patient_treatments, dependent: :destroy
  has_many :patients, through: :patient_treatments
  validates :treatment_type, uniqueness: true
end
