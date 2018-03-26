class CreatePlans < ActiveRecord::Migration[5.1]
  def change
    create_table :plans do |t|
      t.string :title
      t.string :goal
      t.integer :obsession_id

      t.timestamps
    end
  end
end
