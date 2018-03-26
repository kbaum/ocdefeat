class RenameCategoriesTableToThemesTable < ActiveRecord::Migration[5.1]
  def change
    rename_table :categories, :themes # rename_table :old_table_name, :new_table_name
  end
end
