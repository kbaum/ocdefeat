class ChangeDataTypeOfSymptomsToStringInObsessions < ActiveRecord::Migration[5.1]
  def change
    change_column :obsessions, :symptoms, :string
  end
end
