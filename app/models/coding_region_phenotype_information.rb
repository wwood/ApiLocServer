class CodingRegionPhenotypeInformation < ActiveRecord::Base
  belongs_to :coding_region
  belongs_to :phenotype_information
end
