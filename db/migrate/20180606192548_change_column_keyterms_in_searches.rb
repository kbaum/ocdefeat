class ChangeColumnKeytermsInSearches < ActiveRecord::Migration[5.1]
  def change
    rename_column :searches, :keyterms, :key_terms
  end
end
