class ChangeMinanxietyColumnInSearches < ActiveRecord::Migration[5.1]
  def change
    rename_column :searches, :min_anxiety, :min_anxiety_rating
  end
end
