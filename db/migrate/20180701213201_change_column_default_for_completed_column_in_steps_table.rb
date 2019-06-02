class ChangeColumnDefaultForCompletedColumnInStepsTable < ActiveRecord::Migration[5.1]
  def change
    change_column_default :steps, :completed, false
  end
end
