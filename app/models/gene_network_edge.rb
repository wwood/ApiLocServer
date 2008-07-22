class GeneNetworkEdge < ActiveRecord::Base
  belongs_to :gene_network
  
  belongs_to :gene_1,
    :foreign_key => 'gene_id_first',
    :class_name => 'Gene'
  belongs_to :gene_2,
    :foreign_key => 'gene_id_second',
    :class_name => 'Gene'
end
