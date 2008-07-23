class CodingRegionNetworkEdge < ActiveRecord::Base
  belongs_to :network
  belongs_to :coding_region_1,
    :foreign_key => 'coding_region_id_1',
    :class => 'CodingRegion'
  belongs_to :coding_region_2,
    :foreign_key => 'coding_region_id_1',
    :class => 'CodingRegion'
  
  # There is no order to the ids, so it there is 2 possible ways to find
  # the edge between 2 coding regions
  def self.find_by_coding_region_ids(network_name, id1, id2)
    CodingRegionNetworkEdge.first(
      :include => :network,
      :conditions => ['networks.name = ? and ((coding_region_1 = ? and coding_region_2 = ?) or (coding_region_1 = ? and coding_region_2 = ?))', 
        network_name, 
        id1, id2,
        id2, id1
      ]
    )
  end
    
end
