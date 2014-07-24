class CreateCards < ActiveRecord::Migration
  def change
    create_table :cards do |t|
      t.date :schedule
      t.integer :type
      
      t.belongs_to :user

      t.timestamps
    end
  end
end
