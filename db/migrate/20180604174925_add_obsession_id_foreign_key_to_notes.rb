class AddObsessionIdForeignKeyToNotes < ActiveRecord::Migration[5.1]
  def change
    add_column :notes, :obsession_id, :integer
  end
end
