class RenameDoneColumnAccomplishedInPlans < ActiveRecord::Migration[5.1]
  def change
    rename_column :plans, :done, :accomplished
  end
end
