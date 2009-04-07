class Network < ActiveRecord::Base
  has_many :coding_region_network_edges, :dependent => :destroy
  
  WORMNET_NAME = GeneNetwork.wormnet_name
  WORMNET_CORE_CUTOFF_STRENGTH =  0.405465108108  #scores 0.405465108108 (natural log of 1.5) and above were taken in the Lee paper to be the 'core' network

  LACOUNT_2005_NAME = 'LaCount et al. Nature 2005 P. falciparum Yeast Two Hybrid'
  WUCHTY_2009_NAME = 'Wuchty et al. Proteomics 2009 Interaction Map'
end
