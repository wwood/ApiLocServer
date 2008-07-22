# 
# To change this template, choose Tools | Templates
# and open the template in the editor.
require 'transmembrane' 

class MemsatParser
  def parse(filename)
    record = false
    protein = TransmembraneProtein.new
    
    File.open(filename).each do |line|
      if !record and line.match('================')
        record = true
      elsif record
        
        # return if finished this block
        if line.strip === ''
          return protein
        end
        
        matches = line.match('^1: \S+? (\d+)-(\d+)')
        if matches
          tmd = TransmembraneDomain.new
          tmd.start = matches[1].to_i
          tmd.stop = matches[2].to_i
          protein.push tmd
        else
          matches = line.match('^\d+: (\d+)-(\d+)')
          if !matches
            raise Exception, "Badly parsed line: #{line}"
          else
            tmd = TransmembraneDomain.new
            tmd.start = matches[1].to_i
            tmd.stop = matches[2].to_i
            protein.push tmd           
          end
        end
      end
    end
    
    # no tmds found, return empty
    return protein
  end
end
