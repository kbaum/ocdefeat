class AddProgressColumnToPlans < ActiveRecord::Migration[5.1]
  def change
    add_column :plans, :progress, :integer, default: 0
  end
end
