class AddTwitterHandleColumnToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :twitter_handle, :string
  end
end
