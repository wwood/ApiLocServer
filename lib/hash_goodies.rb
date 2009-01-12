# 
# Extra stuff for a hash
 

require 'array_pair'

class Hash
  # Assuming the hash is made key => numeric pairs,
  # return a hash that is normalized ie. all the values are percentages
  # instead of absolute numbers
  def normalize
    total = values.sum.to_f
    normalized = {}
    each do |key, numeric|
      normalized[key] = numeric.to_f/total
    end
    return normalized
  end
end
