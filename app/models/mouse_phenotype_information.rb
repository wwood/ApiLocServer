class MousePhenotypeInformation < ActiveRecord::Base
  has_many :coding_region_mouse_phenotype_informations
  has_many :coding_regions, :through => :coding_region_mouse_phenotype_informations
  
  has_one :mouse_pheno_desc
end
