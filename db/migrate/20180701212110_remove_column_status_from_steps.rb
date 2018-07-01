class RemoveColumnStatusFromSteps < ActiveRecord::Migration[5.1]
  def change
    remove_column :steps, :status
  end
end
