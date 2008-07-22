class MicroarrayMeasurement < ActiveRecord::Base
  belongs_to :microarray_timepoint
  belongs_to :coding_region
end
