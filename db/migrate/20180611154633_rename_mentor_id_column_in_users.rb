class RenameMentorIdColumnInUsers < ActiveRecord::Migration[5.1]
  def change
    rename_column :users, :mentor_id, :counselor_id
  end
end
