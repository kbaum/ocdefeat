class DropObsessionThemes < ActiveRecord::Migration[5.1]
  def change
    drop_table :obsession_themes
  end
end
