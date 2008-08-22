# version was an idea that never went anywhere, and is cruft
class RemoveVersionFromOrthomclGroup < ActiveRecord::Migration
  def self.up
    remove_column :orthomcl_groups, :version
  end

  def self.down
    add_column :orthomcl_groups, :version, :integer
  end
end
