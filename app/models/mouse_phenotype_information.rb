class MousePhenotypeInformation < ActiveRecord::Base
  has_many :coding_region_mouse_phenotype_information
  has_many :coding_regions, :through => :coding_region_mouse_phenotype_information
  
  belongs_to :mouse_pheno_desc
end
