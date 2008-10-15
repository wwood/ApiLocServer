class MicroarrayMeasurement < ActiveRecord::Base
  belongs_to :microarray_timepoint
  belongs_to :coding_region
  
  # a single allowed timepoint name
  named_scope :timepoint_name, lambda {|timepoint_name|
    {
      :joins => :microarray_timepoint,
      :conditions => ['microarray_timepoints.name = ?', timepoint_name]
    }
  }
  # an array of allowed timepoints
  named_scope :timepoint_names, lambda {|timepoint_names_array|
    {
      :joins => :microarray_timepoint,
      :conditions => ["microarray_timepoints.name in ('#{timepoint_names_array.join("','")}')"]
    }
  }
end
