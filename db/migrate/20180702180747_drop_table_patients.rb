class DropTablePatients < ActiveRecord::Migration[5.1]
  def change
    drop_table :patients
  end
end
