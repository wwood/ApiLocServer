class SpeedUpOrthomclGeneCodingRegion < ActiveRecord::Migration
  def self.up
    add_index :orthomcl_gene_coding_regions, :orthomcl_gene_id
    add_index :orthomcl_gene_coding_regions, :coding_region_id
  end

  def self.down
    remove_index :orthomcl_gene_coding_regions, :orthomcl_gene_id
    remove_index :orthomcl_gene_coding_regions, :coding_region_id
  end
end
