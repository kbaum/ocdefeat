class RemoveBioColumnFromUsers < ActiveRecord::Migration[5.1]
  def change
    remove_column :users, :bio
  end
end
