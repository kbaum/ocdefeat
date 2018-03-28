class ChangeDefaultRoleRequestedInUsers < ActiveRecord::Migration[5.1]
  def change
    change_column_default :users, :role_requested, 'Patient'
  end
end
