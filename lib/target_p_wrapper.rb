 

class TargetPWrapper
  # Return a bioruby targetp object once targetp has been run on the given sequence (which is just letters)
  def targetp(sequence)
    Tempfile.open('targetp_in') { |tempfilein|
      # Write a fasta to the tempfile
      tempfilein.puts '>wrapperSeq'
      tempfilein.puts "#{sequence}"
      tempfilein.close #required. Maybe because it doesn't flush otherwise?
      
      Tempfile.open('targetp_out') {|out|
        result = system("targetp #{tempfilein.path} >#{out.path}")
        
        if !result
          raise Exception, "Running targetp program failed. See $? for details."
        end
        line = tempfilein.read
        return Bio::TargetP::Report.new(line)
      }
    }
  end
end
