class OrthomclGeneCodingRegion < ActiveRecord::Base
  belongs_to :orthomcl_gene
  belongs_to :coding_region
end
