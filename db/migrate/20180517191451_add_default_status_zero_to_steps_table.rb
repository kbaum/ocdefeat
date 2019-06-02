class AddDefaultStatusZeroToStepsTable < ActiveRecord::Migration[5.1]
  def change
    change_column :steps, :status, :integer, :default => 0
  end
end
