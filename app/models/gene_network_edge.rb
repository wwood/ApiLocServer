class GeneNetworkEdge < ActiveRecord::Base
  belongs_to :gene_network
  
  belongs_to :gene_1,
    :foreign_key => 'gene_id_first',
    :class_name => 'Gene'
  belongs_to :gene_2,
    :foreign_key => 'gene_id_second',
    :class_name => 'Gene'
  
  # There is no order to the ids, so it there is 2 possible ways to find
  # the edge between 2 coding regions
  def self.find_by_gene_ids(network_name, id1, id2)
    GeneNetworkEdge.first(
      :include => :gene_network,
      :conditions => ['gene_networks.name = ? and ((gene_id_first = ? and gene_id_second = ?) or (gene_id_first = ? and gene_id_second = ?))', 
        network_name, 
        id1, id2,
        id2, id1
      ]
    )
  end
end
