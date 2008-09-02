class FasterOrthomclGeneName < ActiveRecord::Migration
  def self.up
    add_index :orthomcl_genes, :orthomcl_name
  end

  def self.down
    remove_index :orthomcl_genes, :orthomcl_name
  end
end
