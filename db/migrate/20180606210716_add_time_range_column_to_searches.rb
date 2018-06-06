class AddTimeRangeColumnToSearches < ActiveRecord::Migration[5.1]
  def change
    add_column :searches, :time_range, :float
  end
end
