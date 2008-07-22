class PlasmodbGeneList < ActiveRecord::Base
  has_many :plasmodb_gene_list_entries, :dependent => :destroy
  has_many :coding_regions, :through => :plasmodb_gene_list_entries
end
