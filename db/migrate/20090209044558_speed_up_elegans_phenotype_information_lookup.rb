class SpeedUpElegansPhenotypeInformationLookup < ActiveRecord::Migration
  def self.up
    add_index :coding_region_phenotype_informations, [:phenotype_information_id]
    add_index :coding_region_phenotype_informations, [:coding_region_id]
  end

  def self.down
    remove_index :coding_region_phenotype_informations, [:phenotype_information_id]
    remove_index :coding_region_phenotype_informations, [:coding_region_id]
  end
end
