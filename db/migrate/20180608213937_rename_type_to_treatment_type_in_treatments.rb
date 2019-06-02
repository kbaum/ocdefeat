class RenameTypeToTreatmentTypeInTreatments < ActiveRecord::Migration[5.1]
  def change
    rename_column :treatments, :type, :treatment_type
  end
end
