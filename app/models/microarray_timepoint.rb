# Cannot just include directly because otherwise it can get loaded
# twice, causing annoying warnings to be spewed to the command line
require 'microarray_timepoint_constants'

class MicroarrayTimepoint < ActiveRecord::Base
  has_many :microarray_measurements, :dependent => :destroy
  has_one :localisation_median_microarray_measurement, :dependent => :destroy
  belongs_to :microarray

  # a single allowed timepoint name
  named_scope :microarray_name, lambda {|microarray_name|
    {
      :joins => :microarray,
      :conditions => ['microarrays.description = ?', microarray_name]
    }
  }
  
  include MicroarrayTimepointNames

  def self.get_derisi_3d7_localisation_median_name(localisation, timepoint)
    "DeRisi #{localisation} Median Timepoint #{timepoint}"
  end

  def self.get_derisi_3d7_localisation_median_names_sql(localisation)
    "DeRisi #{localisation} Median Timepoint %"
  end
end
