class CreateSteps < ActiveRecord::Migration[5.1]
  def change
    create_table :steps do |t|
      t.text :instructions
      t.integer :duration
      t.integer :discomfort_degree
      t.integer :plan_id
      t.integer :status

      t.timestamps
    end
  end
end
