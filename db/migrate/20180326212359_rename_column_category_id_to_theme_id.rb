class RenameColumnCategoryIdToThemeId < ActiveRecord::Migration[5.1]
  def change
    rename_column :obsession_themes, :category_id, :theme_id
  end
end
