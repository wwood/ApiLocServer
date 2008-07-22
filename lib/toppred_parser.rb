require 'transmembrane' 

class ToppredParser
  def initialize(filename)
    @file = File.open(filename)
  end
  
  # return the next TransmembraneProtein prediction, or nil if there is
  # none left
  def next_prediction
    # search for the sequence line, record name
    line = @file.gets
    reg = 'Sequence : (.*)  \(\d+ res\)$'
    while !line.match(reg)
      line = @file.gets
      
      # no more sequences means end of file
      if line.nil?
        return nil
      end
    end
    protein = TransmembraneProtein.new
    protein.name = line.strip.match(reg)[1]
    
    
    
    # search for the 'Found: ' line to get the number of segments.
    # if 0, return somethng empty
    reg = 'Found: (\d) segments\n'
    while !line.match(reg)
      line = @file.gets
      
      # no more sequences means end of file
      if line.nil?
        raise Exception, "Badly parsed toppred file: no 'Found: X segments' bit after sequence id"
      end
    end
    # found no segments so just return something empty
    if line.match(reg)[1].to_i == 0
      return protein
    end
    
    
    
    # if a segment was found, return the first prediction as it is the best
    # (except for the prob=0 bug, which I'll ignore)
    
    # Transmembranes will be defined by all of the transmembrane domains between here and the next // line
    while !line.match('^//')
      if line.match('^TRANSMEM')
        splits = line.split
        tmd = TransmembraneDomain.new
        tmd.start = splits[1].to_i
        tmd.stop = splits[2].to_i
        protein.transmembrane_domains.push tmd
      end
      
      line = @file.gets
    end
    
    return protein
  end
end
