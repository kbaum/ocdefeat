class ChangeRitualsDatatypeToTextInObsessions < ActiveRecord::Migration[5.1]
  def change
    change_column :obsessions, :rituals, :text
  end
end
