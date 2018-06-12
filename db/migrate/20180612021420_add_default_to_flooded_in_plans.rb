class AddDefaultToFloodedInPlans < ActiveRecord::Migration[5.1]
  def change
    change_column_default :plans, :flooded, from: nil, to: false
  end
end
