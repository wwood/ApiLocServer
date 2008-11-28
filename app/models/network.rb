class Network < ActiveRecord::Base
  has_many :coding_region_network_edges, :dependent => :destroy
  
  WORMNET_NAME = GeneNetwork.wormnet_name
  WORMNET_CORE_CUTOFF_STRENGTH =  0.405465108108  #scores 0.405465108108 (natural log of 1.5) and above were taken in the Lee paper to be the 'core' network
end
