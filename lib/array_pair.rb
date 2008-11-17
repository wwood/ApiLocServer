
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
  
  #  Run the method given on each member of the array, then
  #  collect and return the results
  def pick(method_symbol)
    return collect{|element|
      element.send(method_symbol)
    }
  end
  
  # so intuitively the opposite of Array.reject
  alias_method(:accept, :select)
  
  # Assuming this array is an array of array of numeric/nil values,
  # return the array with each of the columns normalised
  #
  # This is simple linear scaling to [0,1], so each value v is transformed by
  # transformed = (v-minima)/(maxima_minima)
  # nil values are ignored.
  #
  # Doesn't modify the underlying array of arrays in any way, but returns
  # the normalised array
  def normalise_columns
    column_maxima = []
    column_minima = []
    
    # work out how to normalise the array
    each do |row|
      row.each_with_index do |col, index|
        raise Exception, "Unexpected entry class found in array to normalise - expected numeric or nil: #{col}" unless col.nil? or col.kind_of?(Numeric)
        
        # maxima
        if column_maxima[index]
          if !col.nil? and col > column_maxima[index]
            column_maxima[index] = col
          end
        else
          # set it - doesn't matter if it is nil in the end
          column_maxima[index] = col
        end
        
        #minima
        if column_minima[index]
          if !col.nil? and col < column_minima[index]
            column_minima[index] = col
          end
        else
          # set it - doesn't matter if it is nil in the end
          column_minima[index] = col
        end
      end
    end
    
    # now do the actual normalisation
    to_return = []
    each do |row|
      new_row = []
      row.each_with_index do |col, index|
        minima = column_minima[index]
        maxima = column_maxima[index]
      
        if col.nil?
          new_row.push nil
        elsif minima == maxima
          new_row.push 0.0
        else
          new_row.push((col.to_f-minima.to_f)/((maxima-minima).to_f))
        end
      end
      to_return.push new_row
    end
    return to_return
  end
  
  # make a hash out the array by mapping [element0, element1] to
  # {element0 => 0, element1 => 1}. Raises an Exception if 2 elements
  # are the same. nil elements are ignored.
  def to_hash
    hash = {}
    each_with_index do |element, index|
      next if element.nil?
      raise Exception, "Multiple elements for #{element}" if hash[element]
      hash[element] = index
    end
    hash
  end
end