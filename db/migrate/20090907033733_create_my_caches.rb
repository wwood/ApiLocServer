class CreateMyCaches < ActiveRecord::Migration
  def self.up
    create_table :my_caches do |t|
      t.string :name, :null => false
      t.text :cache, :null => false

      t.timestamps
    end

    add_index :my_caches, :name, :null => false
  end

  def self.down
    drop_table :my_caches
  end
end
