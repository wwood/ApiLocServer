
# An added method for an array class that return the pairs of classes
class Array
  # Return an array of all pairs of elements from this array (each is an array).
  #
  # NOT thread safe.
  def pairs
    pairs = []
    (0..length-1).each do |index1|
      index2 = index1+1
      while index2 < length
        pairs.push [self[index1], self[index2]]
        index2 += 1
      end
    end
    return pairs
  end
end
