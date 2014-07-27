class AddStudyCountToUsers < ActiveRecord::Migration
  def change
    add_column :users, :last_study_date, :date
    add_column :users, :study_card_count, :integer
    add_column :users, :study_new_word_count, :integer
  end
end
