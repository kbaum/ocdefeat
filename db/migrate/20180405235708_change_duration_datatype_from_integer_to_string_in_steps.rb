class ChangeDurationDatatypeFromIntegerToStringInSteps < ActiveRecord::Migration[5.1]
  def change
    change_column :steps, :duration, :string
  end
end
