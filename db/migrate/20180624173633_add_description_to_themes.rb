class AddDescriptionToThemes < ActiveRecord::Migration[5.1]
  def change
    add_column :themes, :description, :string
  end
end
