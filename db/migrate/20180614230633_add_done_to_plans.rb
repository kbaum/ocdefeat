class AddDoneToPlans < ActiveRecord::Migration[5.1]
  def change
    add_column :plans, :done, :boolean
  end
end
