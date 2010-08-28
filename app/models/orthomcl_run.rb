class OrthomclRun < ActiveRecord::Base
  has_many :orthomcl_gene_orthomcl_group_orthomcl_runs, :dependent => :destroy
  has_many :orthomcl_genes, :through => :orthomcl_gene_orthomcl_group_orthomcl_runs, :dependent => :destroy
  has_one :orthomcl_groups, :through => :orthomcl_gene_orthomcl_group_orthomcl_runs, :dependent => :destroy
  
  ORTHOMCL_OFFICIAL_VERSION_4_NAME = 'Official OrthoMCL v4'
  ORTHOMCL_OFFICIAL_VERSION_3_NAME = 'Official OrthoMCL v3'
  ORTHOMCL_OFFICIAL_VERSION_2_NAME = 'Official OrthoMCL v2'
  ORTHOMCL_OFFICIAL_NEWEST_NAME = ORTHOMCL_OFFICIAL_VERSION_3_NAME
  
  named_scope :official, {
    :conditions => {:name => ORTHOMCL_OFFICIAL_NEWEST_NAME}
  }
  
  # Given a version name, return the corresponding download dir.
  # E.g. 'Official OrthoMCL v4' => 'v4'
  def self.version_name_to_local_data_dir(orthomcl_version_name)
    return "v#{version_name_to_number(orthomcl_version_name)}"
  end
  
  # Given a version name, return the corresponding number.
  # E.g. 'Official OrthoMCL v4' => 4
  def self.version_name_to_number(orthomcl_version_name)
    if matches = orthomcl_version_name.match(/^Official OrthoMCL v(\d+)$/)
      num = matches[1].to_i
      if num = num.to_i
        return num.to_i #whole numbered releases
      else
        return num #not whole numbered releases, e.g. 2.2
      end
    else
      raise Exception, "Could not parse orthomcl version name: `#{orthomcl_version_name}'"
    end
  end
  
  def self.groups_gz_filename(orthomcl_version_name)
    "groups_OrthoMCL-#{version_name_to_number(orthomcl_version_name)}.txt.gz" 
  end 
  
  def self.deflines_gz_filename(orthomcl_version_name)
    "aa_deflines_OrthoMCL-#{version_name_to_number(orthomcl_version_name)}.txt.gz" 
  end
  
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
