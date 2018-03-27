class AddSeverityToUsersTable < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :severity, :string
  end
end
