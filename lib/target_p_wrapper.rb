require 'tempfile' 
require 'bio'

class TargetPWrapper
  # PLANT or NON-PLANT as per signalp
  attr_accessor :network
  
  PLANT = 'PLANT'
  NON_PLANT = 'NON-PLANT'
  
  # Return a bioruby targetp object once targetp has been run on the given sequence (which is just letters)
  def targetp(sequence)
    Tempfile.open('targetp_in') { |tempfilein|
      # Write a fasta to the tempfile
      tempfilein.puts '>wrapperSeq'
      tempfilein.puts "#{sequence}"
      tempfilein.close #required. Maybe because it doesn't flush otherwise?
      
      Tempfile.open('targetp_out') {|out|
        args = ''
        if @network and @network === PLANT
          args = " -P"
        end
        result = system("targetp #{args} #{tempfilein.path} >#{out.path}")
        
        if !result
          raise Exception, "Running targetp program failed. See $? for details."
        end
        line = out.open.read
        #        puts line
        return Bio::TargetP::Report.new(line)
      }
    }
  end
  
  def set_plant
    @network = PLANT
  end
  
  def set_non_plant
    @network = NON_PLANT
  end
end
