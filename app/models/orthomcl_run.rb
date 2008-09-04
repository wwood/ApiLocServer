class OrthomclRun < ActiveRecord::Base
  has_many :orthomcl_groups, :dependent => :destroy
  
  def self.official_run_v2_name
    'Official OrthoMCL v2'
  end
  
  def self.official_run_v2
    return OrthomclRun.find_or_create_by_name(official_run_v2_name)
  end
  
  def self.seven_species_no_filtering_name
    'Seven species for Babesia (no low complex filter)'
  end
  
  def self.seven_species_filtering_name
    'Seven species for Babesia'
  end
  def self.seven_species_name
    Species.seven_species_filtering_name
  end
end
