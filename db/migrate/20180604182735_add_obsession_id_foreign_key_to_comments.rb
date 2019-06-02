class AddObsessionIdForeignKeyToComments < ActiveRecord::Migration[5.1]
  def change
    add_column :comments, :obsession_id, :integer
  end
end
