class ChangeIntrusiveThoughtDatatypeToTextInObsessions < ActiveRecord::Migration[5.1]
  def change
    change_column :obsessions, :intrusive_thought, :text
  end
end
