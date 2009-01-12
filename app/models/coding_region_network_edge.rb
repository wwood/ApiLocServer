class CodingRegionNetworkEdge < ActiveRecord::Base
  belongs_to :network
  belongs_to :coding_region_1,
    :foreign_key => 'coding_region_id_first',
    :class_name => 'CodingRegion'
  belongs_to :coding_region_2,
    :foreign_key => 'coding_region_id_second',
    :class_name => 'CodingRegion'
  
  named_scope :coding_region_ids, lambda{ |coding_region_id_1, coding_region_id_2|
    {
      :conditions => ['(coding_region_id_first = ? and coding_region_id_second = ?) or (coding_region_id_first = ? and coding_region_id_second = ?)', 
        coding_region_id_1, coding_region_id_2,
        coding_region_id_2, coding_region_id_1
      ]
    }
  }
  named_scope :coding_region_id, lambda{ |coding_region_id_1|
    {
      :conditions => ['(coding_region_id_first = ?) or (coding_region_id_second = ?)', 
        coding_region_id_1,
        coding_region_id_1
      ]
    }
  }
  named_scope :network_name, lambda {|network_name|
    {
      :include => :network,
      :conditions => ['networks.name = ?', network_name]
    }
  }
  named_scope :wormnet, lambda {
    {
      :include => :network,
      :conditions => ['networks.name = ?', 
        Network::WORMNET_NAME
      ]
    }
  } 
  named_scope :wormnet_core, lambda {
    {
      :include => :network,
      :conditions => ['strength >=? and networks.name = ?', 
        Network::WORMNET_CORE_CUTOFF_STRENGTH,
        Network::WORMNET_NAME
      ]
    }
  } 
end
