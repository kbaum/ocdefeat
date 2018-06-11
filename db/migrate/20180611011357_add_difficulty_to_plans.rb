class AddDifficultyToPlans < ActiveRecord::Migration[5.1]
  def change
    add_column :plans, :difficulty, :string
  end
end
