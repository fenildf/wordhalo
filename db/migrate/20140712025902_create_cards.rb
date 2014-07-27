class CreateCards < ActiveRecord::Migration
  def change
    create_table :cards do |t|
      t.datetime :schedule
      t.integer :study_count
      t.boolean :pending
      t.string :study_type
      
      t.belongs_to :word
      
      t.belongs_to :user

      t.timestamps
    end
  end
end
