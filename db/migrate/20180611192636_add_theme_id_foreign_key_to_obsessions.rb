class AddThemeIdForeignKeyToObsessions < ActiveRecord::Migration[5.1]
  def change
    add_column :obsessions, :theme_id, :integer
  end
end
