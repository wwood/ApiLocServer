class CreateCodingRegionCompartmentCaches < ActiveRecord::Migration
  def self.up
    create_table :coding_region_compartment_caches do |t|
      t.integer :coding_region_id, :null => false
      t.string :compartment, :null => false

      t.timestamps
    end
    
    add_index :coding_region_compartment_caches, :coding_region_id
    add_foreign_key :coding_region_compartment_caches, :coding_regions, :dependent => :delete
  end

  def self.down
    drop_table :coding_region_compartment_caches
  end
end
