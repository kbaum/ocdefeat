class ChangeSymptomsDatatypeToTextInObsessions < ActiveRecord::Migration[5.1]
  def change
    change_column :obsessions, :symptoms, :text
  end
end
