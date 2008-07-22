# Take an HTML file, and then for each form in it, work out the firefox
# bookmark style upload of it.

class FormParser
  
  # Return an array of forms that can be converted to %s method
  def get_forms(html_string)
    # Split on 
    splits = html_string.split('</form>')
    
    # Do nothing if no forms are found
    if !splits or splits.length < 2
      return
    end
    
    #Delete up to the start of the form
    (0..splits.length-2).to_a.each do |i|
      form = 
    end
  end
end

class Form
  attr_accessor :elements
  attr_accessor :base_url
  attr_accessor :first_separator
  attr_accessor :other_separator
  
  # Defaults ones
  @first_separator = '?'
  @other_separator = '&'
  
  def firefox_style
    "#{@base_url}#{@first_separator}#{@elements.collect{ |el|
    el.firefox_style
    }.join @other_separator}"
  end
end

class FormElement
  attr_accessor :key
  attr_accessor :value
  
  SEPARATOR = '='
  
  def initialize(key, value)
    @key = key
    @value = value
  end
  
  def firefox_style
    "#{@key}#{SEPARATOR}#{@value}"
  end
end
