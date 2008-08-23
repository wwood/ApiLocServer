class PhenotypeInformation < ActiveRecord::Base
  has_many :coding_region_phenotype_informations, :dependent => :destroy
  has_many :coding_regions, :through => :coding_region_phenotype_informations
end
