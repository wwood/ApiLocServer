class OrthomclOfficialDataIndex < ActiveRecord::Migration
  def self.up
    add_index :orthomcl_gene_official_datas, :orthomcl_gene_id, :unique => true
  end

  def self.down
    remove_index :orthomcl_gene_official_datas, :orthomcl_gene_id
  end
end
