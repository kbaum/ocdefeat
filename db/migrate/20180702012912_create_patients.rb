class CreatePatients < ActiveRecord::Migration[5.1]
  def change
    create_table :patients do |t|
      t.string :name
      t.string :email
      t.string :password_digest
      t.string :uid
      t.string :provider
      t.string :severity
      t.string :variant
      t.integer :therapist_id

      t.timestamps
    end
  end
end
