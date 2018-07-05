class CreateObsessions < ActiveRecord::Migration[5.1]
  def change
    create_table :obsessions do |t|
      t.string :intrusive_thought
      t.string :triggers
      t.integer :anxiety_rating
      t.string :symptoms
      t.string :rituals
      t.integer :user_id
      t.integer :time_consumed

      t.timestamps
    end
  end
end
