class ChangeTriggersDatatypeToTextInObsessions < ActiveRecord::Migration[5.1]
  def change
    change_column :obsessions, :triggers, :text
  end
end
