class DeleteMinTimeConsumedColumnFromSearches < ActiveRecord::Migration[5.1]
  def change
    remove_column :searches, :min_time_consumed
  end
end
