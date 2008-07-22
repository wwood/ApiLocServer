class CreateSequences < ActiveRecord::Migration
  def self.up
    create_table :sequences do |t|
      t.string :type, :null => false
      t.integer :coding_region_id, :null => false
      t.text :sequence, :null => false

      t.timestamps
    end
    
    add_index :sequences, [:coding_region_id], :unique => true
  end

  def self.down
    drop_table :sequences
  end
end
