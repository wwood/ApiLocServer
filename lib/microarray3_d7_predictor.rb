

require 'k_fold_cross_validator'

# Predicts localisation based on microarray data from the 3D7 experiment alone
class Microarray3D7Predictor<Prediction::AbstractPredictor
  def train(data)
    # for each coding region in the data set, record the median maximum time of expression
#    CodingRegion.find(data.keys,
#      :include => {:microarray_measurements => }
#    :conditions => 
#    )
  end
  
  def validate(data)
    
  end
end
