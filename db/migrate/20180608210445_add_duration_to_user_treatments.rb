class AddDurationToUserTreatments < ActiveRecord::Migration[5.1]
  def change
    add_column :user_treatments, :duration, :string
  end
end
