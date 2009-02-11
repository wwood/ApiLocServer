class DropBadlyDesignedIndex < ActiveRecord::Migration
  def self.up
    remove_index :orthomcl_gene_orthomcl_group_orthomcl_runs, :name => 'ogor'
  end

  def self.down
  end
end
