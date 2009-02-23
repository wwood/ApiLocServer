class SpeedUpOrthomclGroupName < ActiveRecord::Migration
  def self.up
    add_index :orthomcl_groups, :orthomcl_name
  end

  def self.down
    remove_index :orthomcl_groups, :orthomcl_name
  end
end
