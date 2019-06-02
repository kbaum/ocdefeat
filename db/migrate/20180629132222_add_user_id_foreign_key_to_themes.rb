class AddUserIdForeignKeyToThemes < ActiveRecord::Migration[5.1]
  def change
    add_column :themes, :user_id, :integer
  end
end
