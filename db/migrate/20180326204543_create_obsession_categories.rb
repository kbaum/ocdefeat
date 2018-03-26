class CreateObsessionCategories < ActiveRecord::Migration[5.1]
  def change
    create_table :obsession_categories do |t|
      t.integer :obsession_id
      t.integer :category_id

      t.timestamps
    end
  end
end
