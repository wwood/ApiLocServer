class GeneNetwork < ActiveRecord::Base
  has_many :gene_network_edges, :dependent => :destroy
  
  def self.wormnet_name
    'Wormnet'
  end
end
