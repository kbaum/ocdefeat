class AddReferencesColumnToUsers < ActiveRecord::Migration[5.1]
  def change
    add_reference :users, :counselor, foreign_key: true
  end
end
