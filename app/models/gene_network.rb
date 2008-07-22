class GeneNetwork < ActiveRecord::Base
  has_many :gene_network_edges
  
  def self.wormnet_name
    'Wormnet'
  end
end
