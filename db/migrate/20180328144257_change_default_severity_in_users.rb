class ChangeDefaultSeverityInUsers < ActiveRecord::Migration[5.1]
  def change
    change_column_default :users, :severity, 'mild'
  end
end
