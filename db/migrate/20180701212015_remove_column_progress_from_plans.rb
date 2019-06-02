class RemoveColumnProgressFromPlans < ActiveRecord::Migration[5.1]
  def change
    remove_column :plans, :progress
  end
end
