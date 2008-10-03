class MoreOrthomclSpeedup < ActiveRecord::Migration
  def self.up
    add_index :orthomcl_groups, [:orthomcl_run_id, :orthomcl_name]
  end

  def self.down
    remove_index :orthomcl_groups, [:orthomcl_run_id, :orthomcl_name]
  end
end
