class OrthomclGroup < ActiveRecord::Base
  has_many :orthomcl_genes
  belongs_to :orthomcl_run
end
