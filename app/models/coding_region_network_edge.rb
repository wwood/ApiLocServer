class CodingRegionNetworkEdge < ActiveRecord::Base
  belongs_to :network
  belongs_to :coding_region_1,
    :foreign_key => 'coding_region_id_1',
    :class => 'CodingRegion'
  belongs_to :coding_region_2,
    :foreign_key => 'coding_region_id_1',
    :class => 'CodingRegion'
    
end
