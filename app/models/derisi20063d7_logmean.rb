class Derisi20063d7Logmean < ActiveRecord::Base
  set_table_name 'derisi20063d7logmean'
  belongs_to :coding_region
  
  # Get the array of timepoints
  def timepoints
    return [
      timepoint1, timepoint2, timepoint3, timepoint4, timepoint5, timepoint6,
      timepoint7, timepoint8, timepoint9, timepoint10, timepoint11, timepoint12,
      timepoint13, timepoint14, timepoint15, timepoint16, timepoint17, 
      timepoint18, timepoint19, timepoint20, timepoint21, timepoint22, 
      timepoint23, timepoint24, timepoint25, timepoint26, timepoint27,
      timepoint28, timepoint29, timepoint30, timepoint31, timepoint32, 
      timepoint33, timepoint34, timepoint35, timepoint36, timepoint37, 
      timepoint38, timepoint39, timepoint40, timepoint41, timepoint42, 
      timepoint43, timepoint44, timepoint45, timepoint46, timepoint47,
      timepoint48, timepoint49, timepoint50, timepoint51, timepoint52,
      timepoint53 
    ]
  end
end
