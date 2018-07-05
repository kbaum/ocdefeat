class AddMaxTimeConsumedToSearches < ActiveRecord::Migration[5.1]
  def change
    add_column :searches, :max_time_consumed, :float
  end
end
