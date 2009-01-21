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
  
    
  # The percentile is what percentage of measurements in this class does this
  # measurement beat?
  def percentile
    nil if measurement.nil?
    
    belows = MicroarrayMeasurement.count(
      :conditions => ["microarray_timepoint_id = ? and measurement < ?",
        microarray_timepoint_id,
        measurement
      ]
    )
    total = MicroarrayMeasurement.count(
      :conditions => ['microarray_timepoint_id = ?', microarray_timepoint_id]
    )
    
    return 1.0 if total == 1 #otherwise NaN's happen
    return belows.to_f / (total-1).to_f
  end
end
