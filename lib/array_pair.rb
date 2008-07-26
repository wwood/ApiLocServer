
# An added method for an array class that return the pairs of classes
class Array
  # Return an array of all pairs of elements from this array (each is an array).
  # If another_array is not nil, then do pairwise between this array and that (but not within each)
  #
  # NOT thread safe.
  def pairs(another_array = nil)
    pairs = []
    
    if another_array #between this array and the next
      (0..length-1).each do |index1|
        (0..another_array.length-1).each do |index2|
          pairs.push [self[index1], another_array[index2]]
        end
      end       
    else # within this array only
      (0..length-1).each do |index1|
        index2 = index1+1
        while index2 < length
          pairs.push [self[index1], self[index2]]
          index2 += 1
        end
      end      
    end

    return pairs
  end
  
  
  def average
    sum.to_f / length.to_f
  end
end
