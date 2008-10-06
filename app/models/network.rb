class Network < ActiveRecord::Base
  has_many :coding_region_network_edges, :dependent => :destroy
  
  WORMNET_NAME = GeneNetwork.wormnet_name
  WORMNET_CORE_CUTOFF_STRENGTH = 1.5  #scores 1.5 and above were taken in the Lee paper to be the 'core' network
end
