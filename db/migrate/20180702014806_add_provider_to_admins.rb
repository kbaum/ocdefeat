class AddProviderToAdmins < ActiveRecord::Migration[5.1]
  def change
    add_column :admins, :provider, :string
  end
end
