
# Additions to the Array class so that it is easier to work
# with LIBSVM
class Array
  # Return a String so that this array (which is assumed to be a list
  # of features) can be output in LIBSVM format
  def libsvm_format(class_label)
    str = "#{class_label}"
    each_with_index do |element, index|
      str += " #{index+1}:#{element.to_f}"
    end
    str
  end
end
