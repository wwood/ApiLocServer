class PlasmodbGeneListEntry < ActiveRecord::Base
  belongs_to :plasmodb_gene_list
  belongs_to :coding_region
end
