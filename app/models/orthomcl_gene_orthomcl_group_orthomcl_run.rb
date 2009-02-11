class OrthomclGeneOrthomclGroupOrthomclRun < ActiveRecord::Base
  belongs_to :orthomcl_run
  belongs_to :orthomcl_gene
  belongs_to :orthomcl_group
end
