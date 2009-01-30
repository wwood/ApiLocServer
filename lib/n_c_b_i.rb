require 'rubygems'

require 'bio'
require 'tempfile'
require 'reach' #I should publish this to rubyforge really

module Bio
  class SegmaskerWrapper    
    # Return a SegmaskerResult object corresponding to the Segmask Result
    def self.calculate(amino_acid_sequence)
      Tempfile.open('segmasker_wrapper_input') do |tempfile|
        tempfile.puts ">segmaskerWrapper"
        tempfile.puts amino_acid_sequence
        tempfile.flush

        Tempfile.open('segmasker_wrapper_output') do |tempfile_out|
          system("segmasker <#{tempfile.path} >#{tempfile_out.path}")
          return SegmaskerResult.parse(tempfile_out.read)
        end
      end
    end
  end
  
  class SegmaskerResult
    # An array of low complexity segments ie. SegmaskerSegment objects
    attr_accessor :masked_segments
    
    def self.parse(segmasker_result)
      me = new
      me.masked_segments = []
      
      first = true
      segmasker_result.each do |line|
        if first
          first = false
          next
        end
        
        if (parsed = line.strip.match(/(\d+) \- (\d+)/))
          me.masked_segments.push SegmaskerSegment.new(parsed[1].to_i, parsed[2].to_i)
        else
          raise Exception, "Badly parsed Segmasker Output for line: #{line}"
        end
      end
      
      return me
    end
    
    def total_masked_length
      # Why doesn't ruby have an Array#sum method?
      @masked_segments.slap.length.retract.inject { |sum, element| sum + element }
    end
  end
  
  class SegmaskerSegment
    attr_accessor :start, :stop
      
    def initialize(start, stop)
      @start = start
      @stop = stop
    end
      
    def length
      @stop - @start + 1
    end
  end
end
