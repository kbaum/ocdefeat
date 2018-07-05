class CreateSearches < ActiveRecord::Migration[5.1]
  def change
    create_table :searches do |t|
      t.string :keywords
      t.integer :theme_id
      t.integer :min_anxiety
      t.integer :max_anxiety

      t.timestamps
    end
  end
end
