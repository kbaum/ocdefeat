class AddMinTimeConsumedColumnToSearches < ActiveRecord::Migration[5.1]
  def change
    add_column :searches, :min_time_consumed, :float
  end
end
