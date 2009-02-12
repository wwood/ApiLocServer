class SpeedUpOgogor < ActiveRecord::Migration
  def self.up
    add_index :orthomcl_gene_orthomcl_group_orthomcl_runs, :orthomcl_group_id
  end

  def self.down
    remove_index :orthomcl_gene_orthomcl_group_orthomcl_runs, :orthomcl_group_id
  end
end
