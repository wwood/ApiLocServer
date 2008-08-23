class CodingRegionPhenotypeObserved < ActiveRecord::Base
  belongs_to :coding_region
  belongs_to :phenotype_observed
end
