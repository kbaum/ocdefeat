class DropTips < ActiveRecord::Migration[5.1]
  def change
    drop_table :tips
  end
end
