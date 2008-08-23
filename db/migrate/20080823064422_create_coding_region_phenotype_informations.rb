class CreateCodingRegionPhenotypeInformations < ActiveRecord::Migration
    def self.up
    create_table :coding_region_phenotype_informations do |t|
      t.integer :coding_region_id
      t.integer :phenotype_observed_id

      t.timestamps
    end
    
    # don't allow duplicates - maybe change this when more large experiments are used?
    add_index :coding_region_phenotype_informations, [:coding_region_id, :phenotype_observed_id], :unique => true
    
    # remove old assumption
    remove_column :phenotype_informations, :coding_region_id
  end

  def self.down
    drop_table :coding_region_phenotype_informations
    add_column :phenotype_observed, :coding_region_id, :integer, :null => false
  end
end
