# 
# To change this template, choose Tools | Templates
# and open the template in the editor.
 
require 'api_db_genes'
require 'bio'

# For the moment this only gives back genes, not a fully fledged GFF3
class GFF3ParserFixed < Bio::GFF::GFF3
  def initialize(str = '')
    @records = Array.new
    str.each_line do |line|
      @records << GFF3RecordFixed.new(line)
    end
  end
end

# Bug: Only works with input files, not strings. Fixable but I don't care enough
class GFF3ParserLight
  @io
  
  def initialize(io)
    @io = io
  end
  
  # scan through the io, returning the first feature name of a given type, or nil if none is found
  def each_feature(feature_name)
    while line = @io.gets
      r = GFF3RecordFixed.new(line)
      yield r if r.feature === feature_name
    end
    return nil
  end
  
  # scan through each line of the file
  def each
    while line=@io.gets
      r = GFF3RecordFixed.new(line)
      yield r
    end
  end
end


class GFF3RecordFixed <Bio::GFF::Record
  def parse_attributes(attributes)
    hash = Hash.new
    attributes.split(/;/).each do |atr|
      key, value = atr.split('=', 2)
      hash[key] = value
    end
    return hash
  end
end
