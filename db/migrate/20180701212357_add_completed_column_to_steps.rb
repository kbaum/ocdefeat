class AddCompletedColumnToSteps < ActiveRecord::Migration[5.1]
  def change
    add_column :steps, :completed, :boolean
  end
end
