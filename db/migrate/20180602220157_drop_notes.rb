class DropNotes < ActiveRecord::Migration[5.1]
  def change
    drop_table :notes
  end
end
