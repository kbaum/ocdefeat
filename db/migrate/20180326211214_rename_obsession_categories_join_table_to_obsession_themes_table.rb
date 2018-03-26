class RenameObsessionCategoriesJoinTableToObsessionThemesTable < ActiveRecord::Migration[5.1]
  def change
    rename_table :obsession_categories, :obsession_themes
  end
end
