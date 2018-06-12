class AddDefaultRoleToUsersTable < ActiveRecord::Migration[5.1]
  def change
    change_column_default :users, :role, from: nil, to: 0
  end
end
