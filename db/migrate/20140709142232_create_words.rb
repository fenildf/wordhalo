class CreateWords < ActiveRecord::Migration
  def change
    create_table :words do |t|
      t.integer :version
      t.string :title
      t.string :pronounce
      t.string :serialized_chinese

      t.timestamps
    end
  end
end
