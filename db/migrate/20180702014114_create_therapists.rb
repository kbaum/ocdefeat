class CreateTherapists < ActiveRecord::Migration[5.1]
  def change
    create_table :therapists do |t|
      t.string :name
      t.string :email
      t.string :password_digest
      t.string :uid
      t.string :provider
      t.string :degree
      t.string :board_certifications
      t.string :specialty
      t.integer :years_in_practice

      t.timestamps
    end
  end
end
