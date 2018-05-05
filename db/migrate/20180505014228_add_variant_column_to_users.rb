class AddVariantColumnToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :variant, :string
  end
end
