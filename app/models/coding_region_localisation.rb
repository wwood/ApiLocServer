class CodingRegionLocalisation < ActiveRecord::Base
  belongs_to :coding_region
  belongs_to :localisation
  belongs_to :localisation_method
end
