class RemoveColumnAccomplishedFromPlans < ActiveRecord::Migration[5.1]
  def change
    remove_column :plans, :accomplished
  end
end
