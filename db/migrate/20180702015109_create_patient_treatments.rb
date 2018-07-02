class CreatePatientTreatments < ActiveRecord::Migration[5.1]
  def change
    create_table :patient_treatments do |t|
      t.integer :patient_id
      t.integer :treatment_id
      t.string :efficacy
      t.string :duration

      t.timestamps
    end
  end
end
