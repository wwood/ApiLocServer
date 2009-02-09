class CodingRegionMousePhenotype < ActiveRecord::Base
  belongs_to :coding_region
  belongs_to :mouse_phenotype
end
