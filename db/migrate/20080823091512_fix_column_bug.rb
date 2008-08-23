class FixColumnBug < ActiveRecord::Migration
  def self.up
    rename_column :coding_region_phenotype_informations, :phenotype_observed_id, :phenotype_information_id
  end

  def self.down
    rename_column :coding_region_phenotype_informations,  :phenotype_information_id, :phenotype_observed_id
  end
end
