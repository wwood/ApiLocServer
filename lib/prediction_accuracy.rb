# 
# To change this template, choose Tools | Templates
# and open the template in the editor.
 

class PredictionAccuracy
  # Counts for each of the
  attr_accessor :tp, :fp, :tn, :fn
  
  def initialize(tp = nil, fp = nil, tn = nil, fn = nil)
    @tp = tp
    @fp = fp
    @tn = tn
    @fn = fn
  end
  
  def accuracy
    tp.to_f / fp.to_f
  end
  
  def specificity
    tn.to_f / (tn.to_f + fp.to_f)
  end
  
  def sensitivity
    tp.to_f / (tp.to_f + fn.to_f)
  end
  
  def to_s
    [
      "Accuracy: #{accuracy.round(2)}",
      "Specificity: #{specificity.round(2)}",
      "Sensitivity: #{sensitivity.round(2)}"
    ].join("\n")
  end
end
