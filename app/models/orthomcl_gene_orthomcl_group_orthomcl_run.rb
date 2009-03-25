class OrthomclGeneOrthomclGroupOrthomclRun < ActiveRecord::Base
  belongs_to :orthomcl_run
  belongs_to :orthomcl_gene
  belongs_to :orthomcl_group

  # Find or create using the usual ids
  def self.find_or_create_me(orthomcl_gene_id, orthomcl_group_id, orthomcl_run_id)
    self.find_or_create_by_orthomcl_gene_id_and_orthomcl_group_id_and_orthomcl_run_id(
      orthomcl_gene_id, orthomcl_group_id, orthomcl_run_id
    )
  end
end
