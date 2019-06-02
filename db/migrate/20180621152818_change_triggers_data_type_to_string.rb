class ChangeTriggersDataTypeToString < ActiveRecord::Migration[5.1]
  def change
    change_column :obsessions, :triggers, :string
  end
end
