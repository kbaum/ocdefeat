class RenameDescriptionColumnDefinitionInThemes < ActiveRecord::Migration[5.1]
  def change
    rename_column :themes, :description, :definition
  end
end
