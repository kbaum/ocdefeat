class ChangeKeywordColumnInSearches < ActiveRecord::Migration[5.1]
  def change
    rename_column :searches, :keywords, :keyterms
  end
end
