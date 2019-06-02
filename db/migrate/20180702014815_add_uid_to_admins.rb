class AddUidToAdmins < ActiveRecord::Migration[5.1]
  def change
    add_column :admins, :uid, :string
  end
end
