class RenameMousePhenotypeTables < ActiveRecord::Migration
  def self.up
    rename_table :mouse_phenotype_informations, :mouse_phenotypes
    rename_table :mouse_pheno_descs, :mouse_phenotype_dictionary_entries
    rename_table :coding_region_mouse_phenotype_informations, :coding_region_mouse_phenotypes
    
    rename_column :coding_region_mouse_phenotypes, :mouse_phenotype_information_id, :mouse_phenotype_id
  end

  def self.down
    rename_table :mouse_phenotypes, :mouse_phenotype_informations
    rename_table :mouse_phenotype_dictionary_entries, :mouse_pheno_descs
    rename_table :coding_region_mouse_phenotypes, :coding_region_mouse_phenotype_informations
    
    rename_column :coding_region_mouse_phenotype_informations, :mouse_phenotype_id, :mouse_phenotype_information_id
  end
end
