require 'tempfile'

module Bio
  class Radar
    class Wrapper
      # Run radar.py and return a Bio::Radar::Result
      # object on the (purely sequence, not fasta) string
      def run(sequence)
        output = nil
        
        Tempfile.open('radarin') do |tempfilein|
          # Write a fasta to the tempfile
          tempfilein.puts '>wrapperSeq'
          tempfilein.puts "#{sequence.to_s}"
          tempfilein.close #required. Maybe because it doesn't flush otherwise?

          Tempfile.open('radarout') do |tempfileout|
            result = system("radar.py <#{tempfilein.path} >#{tempfileout.path}")

            if !result
              raise Exception, "Running radar.py program failed. $? is '#{$?.inspect}'"
            end

            output = tempfileout.read
          end
        end

        return Result.create_from_output(output)
      end
    end

    class Result < Array
      def self.create_from_output(output)
        r = self.new

        splits = output.split("\n")
        splits.each do |s|
          if s.match(/No\. of Repeats/)
            r.push Repeat.new
          end
        end

        return r
      end
    end

    class Repeat
      
    end
  end
end
