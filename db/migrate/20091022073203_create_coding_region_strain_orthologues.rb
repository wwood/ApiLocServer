class CreateCodingRegionStrainOrthologues < ActiveRecord::Migration
  def self.up
    create_table :coding_region_strain_orthologues do |t|
      t.integer :coding_region_id, :null => false
      t.string :name, :null => false, :unique => true

      t.timestamps
    end

    add_index :coding_region_strain_orthologues, :name
    add_index :coding_region_strain_orthologues, :coding_region_id
  end

  def self.down
    drop_table :coding_region_strain_orthologues
  end
end
