class AddIndexToWordsTitle < ActiveRecord::Migration
  def change
    add_index :words, :title, unique: true
  end
end
