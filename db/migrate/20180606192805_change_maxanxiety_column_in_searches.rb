class ChangeMaxanxietyColumnInSearches < ActiveRecord::Migration[5.1]
  def change
    rename_column :searches, :max_anxiety, :max_anxiety_rating
  end
end
