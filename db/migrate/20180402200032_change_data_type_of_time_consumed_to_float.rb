class ChangeDataTypeOfTimeConsumedToFloat < ActiveRecord::Migration[5.1]
  def change
    change_column :obsessions, :time_consumed, :float
  end
end
