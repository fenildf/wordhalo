class CreateSentences < ActiveRecord::Migration
  def change
    create_table :sentences do |t|
      t.belongs_to :word
      t.integer :version
      t.integer :index
      t.string :english
      t.string :chinese
      t.string :actual

      t.timestamps
    end
  end
end
