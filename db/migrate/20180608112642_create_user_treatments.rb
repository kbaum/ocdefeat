class CreateUserTreatments < ActiveRecord::Migration[5.1]
  def change
    create_table :user_treatments do |t|
      t.integer :user_id
      t.integer :treatment_id
      t.string :efficacy

      t.timestamps
    end
  end
end
