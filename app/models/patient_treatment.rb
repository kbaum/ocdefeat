class PatientTreatment < ApplicationRecord
  belongs_to :patient
  belongs_to :treatment
end
