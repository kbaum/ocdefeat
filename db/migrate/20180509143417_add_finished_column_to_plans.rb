class AddFinishedColumnToPlans < ActiveRecord::Migration[5.1]
  def change
    add_column :plans, :finished, :boolean, :default => false
  end
end
