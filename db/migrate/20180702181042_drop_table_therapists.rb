class DropTableTherapists < ActiveRecord::Migration[5.1]
  def change
    drop_table :therapists
  end
end
