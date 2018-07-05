class DeleteMaxTimeConsumedFromSearches < ActiveRecord::Migration[5.1]
  def change
    remove_column :searches, :max_time_consumed
  end
end
