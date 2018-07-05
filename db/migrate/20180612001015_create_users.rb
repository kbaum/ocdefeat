class CreateUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :users do |t|
      t.string :name
      t.string :email
      t.string :password_digest
      t.string :uid
      t.string :provider
      t.string :role_requested
      t.string :variant
      t.string :severity
      t.integer :role
    end
  end
end
