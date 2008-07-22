class CreateOrthomclGeneCodingRegions < ActiveRecord::Migration
  def self.up
    create_table :orthomcl_gene_coding_regions do |t|
      t.references :coding_region
      t.references :orthomcl_gene

      t.timestamps
    end
    
    add_index :orthomcl_gene_coding_regions, 
      [:coding_region_id, :orthomcl_gene_id], 
      :unique => true
  end

  def self.down
    drop_table :orthomcl_gene_coding_regions
  end
end
