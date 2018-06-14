class ChangeDatatypeOfAccomplishedToInteger < ActiveRecord::Migration[5.1]
  def change
    change_column :plans, :accomplished, :integer
  end
end
