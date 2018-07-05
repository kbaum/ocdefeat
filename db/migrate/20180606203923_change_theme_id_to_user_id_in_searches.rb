class ChangeThemeIdToUserIdInSearches < ActiveRecord::Migration[5.1]
  def change
    rename_column :searches, :theme_id, :user_id
  end
end
