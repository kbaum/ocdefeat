class RenameChallengingColumnFlooded < ActiveRecord::Migration[5.1]
  def change
    rename_column :plans, :challenging, :flooded
  end
end
