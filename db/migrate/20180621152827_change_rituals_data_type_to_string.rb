class ChangeRitualsDataTypeToString < ActiveRecord::Migration[5.1]
  def change
    change_column :obsessions, :rituals, :string
  end
end
