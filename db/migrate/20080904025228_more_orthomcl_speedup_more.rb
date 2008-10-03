class MoreOrthomclSpeedupMore < ActiveRecord::Migration
  def self.up
    add_index :orthomcl_groups, :orthomcl_run_id
    add_index :orthomcl_runs, :name, :unique => true #not so much for speed as for safety
  end

  def self.down
    remove_index :orthomcl_groups, :orthomcl_run_id
    remove_index :orthomcl_runs, :name
  end
end
