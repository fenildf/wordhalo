class CreateNewWords < ActiveRecord::Migration
  def change
    create_table :new_words do |t|
      t.belongs_to :user
      t.belongs_to :word

      t.timestamps
    end
  end
end
