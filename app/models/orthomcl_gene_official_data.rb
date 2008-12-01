class OrthomclGeneOfficialData < ActiveRecord::Base
  belongs_to :orthomcl_gene
  
  def fasta
    ">#{orthomcl_gene.orthomcl_name}\n#{sequence}"
  end
end
