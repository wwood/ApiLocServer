class MoreSpecificUpstreamRegionTable < ActiveRecord::Migration
  
  # postgres was having problems with the long name of the index,
  # so I named it myself to stop that
  BRAFL_INDEX = 'brafl_uniq_index'
  
  def self.up
    add_column :brafl_upstream_distances, :coding_region_id, :integer
  end

  def self.down
    remove_column(:brafl_upstream_distances, :coding_region_id)
  end
end
