class CreateCodingRegionLocalisations < ActiveRecord::Migration
  def self.up
    create_table :coding_region_localisations do |t|
      t.integer :coding_region_id, :null => false
      t.integer :localisation_id, :null => false

      t.timestamps
    end
    
    add_index :coding_region_localisations, 
      [:coding_region_id, :localisation_id],
      :unique => true
  end

  def self.down
    drop_table :coding_region_localisations
  end
end
