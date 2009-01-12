# 
# To change this template, choose Tools | Templates
# and open the template in the editor.
 

class PredictionAccuracy
  # Counts for each of the
  attr_accessor :tp, :fp, :tn, :fn, :not_predicted
  
  def initialize(tp = nil, fp = nil, tn = nil, fn = nil, not_predicted=nil)
    @tp = tp
    @fp = fp
    @tn = tn
    @fn = fn
    @not_predicted = not_predicted
  end
  
  def not_predicted_parsed
    not_predicted.nil? ? 0 : not_predicted
  end
  
  def precision
    tp.to_f / (tp.to_f+fp.to_f)
  end
  
  def specificity
    tn.to_f / (tn.to_f + fp.to_f)
  end
  
  def sensitivity
    tp.to_f / (tp.to_f + fn.to_f)
  end
  
  alias_method :positive_predictive_value, :precision
  def negative_predictive_value
    tn.to_f / (tn.to_f + fn.to_f)
  end
  
  def coverage
    total.to_f / (total+not_predicted_parsed).to_f
  end
  
  def total
    fp+tp+fn+tn
  end
  
  def accuracy
    (tp+tn).to_f / total.to_f
  end
  
  def to_s
    [
      "Number predicted: #{total}",
      "Coverage: #{coverage.round(2)} #{total}/#{total+not_predicted_parsed}",
      "Actual positives: #{fn+tp}/#{total}",
      "Accuracy: #{accuracy.round(2)}",
      "Precision: #{precision.round(2)}",
      "Negative predictive value: #{negative_predictive_value.round(2)}",
      "Specificity: #{specificity.round(2)}",
      "Sensitivity: #{sensitivity.round(2)}"
    ].join("\n")
  end
end
