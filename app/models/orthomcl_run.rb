class OrthomclRun < ActiveRecord::Base
  has_many :orthomcl_gene_orthomcl_group_orthomcl_runs, :dependent => :destroy
  has_many :orthomcl_genes, :through => :orthomcl_gene_orthomcl_group_orthomcl_runs, :dependent => :destroy
  has_one :orthomcl_groups, :through => :orthomcl_gene_orthomcl_group_orthomcl_runs, :dependent => :destroy

  ORTHOMCL_OFFICIAL_VERSION_3_NAME = 'Official OrthoMCL v3'
  ORTHOMCL_OFFICIAL_VERSION_2_NAME = 'Official OrthoMCL v2'
  ORTHOMCL_OFFICIAL_NEWEST_NAME = ORTHOMCL_OFFICIAL_VERSION_3_NAME

  named_scope :official, {
    :conditions => {:name => ORTHOMCL_OFFICIAL_NEWEST_NAME}
  }

  def self.official_run_v3
    OrthomclRun.find_or_create_by_name(ORTHOMCL_OFFICIAL_VERSION_3_NAME)
  end
  
  def self.official_run_v2_name
    ORTHOMCL_OFFICIAL_VERSION_2_NAME
  end
  
  def self.official_run_v2
    OrthomclRun.find_or_create_by_name(official_run_v2_name)
  end
  
  def self.seven_species_no_filtering_name
    'Seven species for Babesia (no low complex filter)'
  end
  
  def self.seven_species_filtering_name
    'Seven species for Babesia'
  end
  def self.seven_species_name
    self.seven_species_filtering_name
  end
end
