class DropTablePatientTreatments < ActiveRecord::Migration[5.1]
  def change
    drop_table :patient_treatments
  end
end
