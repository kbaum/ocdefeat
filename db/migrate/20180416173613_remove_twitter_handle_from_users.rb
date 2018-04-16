class RemoveTwitterHandleFromUsers < ActiveRecord::Migration[5.1]
  def change
    remove_column :users, :twitter_handle
  end
end
