class CreateTransmembraneDomains < ActiveRecord::Migration
  def self.up
    create_table :transmembrane_domains do |t|
      t.integer :coding_region_id, :null => false
      t.integer :start, :null => false
      t.integer :stop, :null => false
      t.string :type, :null => false

      t.timestamps
    end
    
    add_index :transmembrane_domains, [:coding_region_id, :type]
  end

  def self.down
    drop_table :transmembrane_domains
  end
end
