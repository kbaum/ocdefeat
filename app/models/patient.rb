class Patient < ApplicationRecord
  belongs_to :therapist
  has_many :patient_treatments, dependent: :destroy
  has_many :treatments, through: :patient_treatments
end
