require 'csv'
 
# A class to parse the yeastgfp output file found at
# http://yeastgfp.ucsf.edu/allOrfData.txt
class YeastGfpLocalisation
  attr_reader :localisations
  
  FIRST_LOC_INDEX = 9
  
  def initialize(path)
    @loc_file = CSV.open(path, 'r', "\t")
    row1 = @loc_file.shift
    @localisations = row1[FIRST_LOC_INDEX..(row1.length-2)]
  end
  
  def next_loc
    row = @loc_file.shift
    
    # Assumes that the file is in the correct order, as demonstrated by
    #    uyen@uyen:~/phd/data/yeast/yeastgfp$ awk -F"    " '{print $5}' allOrfData.txt |uniq -c
    #    1 GFP visualized?
    #    4160 visualized
    #    2074 not visualized
    if row[4] != 'visualized'
      return nil
    end
    
    y = YeastLoc.new
    if row[FIRST_LOC_INDEX-1]
      y.localisations = row[FIRST_LOC_INDEX-1].split ','
    end
    y.orf_name = row[1]
    return y
  end
end


class YeastLoc
  attr_accessor :localisations, :orf_name
end
