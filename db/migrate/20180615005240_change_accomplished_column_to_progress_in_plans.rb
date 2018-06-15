class ChangeAccomplishedColumnToProgressInPlans < ActiveRecord::Migration[5.1]
  def change
    change_column :plans, :accomplished, :progress
  end
end
