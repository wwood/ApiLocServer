# Cannot just include directly because otherwise it can get loaded
# twice, causing annoying warnings to be spewed to the command line
require 'microarray_timepoint_constants'

class MicroarrayTimepoint < ActiveRecord::Base
  has_many :microarray_measurements, :dependent => :destroy
  belongs_to :microarray
  
  include MicroarrayTimepointNames
end
