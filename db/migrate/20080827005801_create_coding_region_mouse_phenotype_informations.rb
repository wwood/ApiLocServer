class CreateCodingRegionMousePhenotypeInformations < ActiveRecord::Migration
  def self.up
    create_table :coding_region_mouse_phenotype_informations do |t|
      t.integer :coding_region_id
      t.integer :mouse_phenotype_information_id

      t.timestamps
    end
    add_index :coding_region_mouse_phenotype_informations, [:coding_region_id, :mouse_phenotype_information_id], :unique => true
    remove_column :mouse_phenotype_informations, :gene_id
  end

  def self.down
    drop_table :coding_region_mouse_phenotype_informations
    
    add_column :mouse_phenotype_informations, :gene_id, :integer
  end
end
