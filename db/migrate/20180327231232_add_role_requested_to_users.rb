class AddRoleRequestedToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :role_requested, :string
  end
end
