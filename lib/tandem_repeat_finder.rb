require 'tempfile'
require 'rio'

module Bio
  class TandemRepeatFinder
    class Wrapper
      # Run TRF (Tandem Repeat Finder) and return a TandemRepeatFinderResult
      # object on the (purely sequence, not fasta) string
      def run(sequence)
        output = nil

        Tempfile.open('trfin') { |tempfilein|
          # Write a fasta to the tempfile
          tempfilein.puts '>wrapperSeq'
          tempfilein.puts "#{sequence.to_s}"
          tempfilein.close #required. Maybe because it doesn't flush otherwise?


          # Execute the program in a temporary directory so that
          # the .dat file trf spits out is temporary
          
          Tempdir.new('trf') do |d|
            Dir.chdir(d) do
              result = system("trf #{tempfilein.path} 2 7 7 80 10 50 500 -h >/dev/null 2>/dev/null")
              if !result
                raise Exception, "Running tandem repeat finder program failed. See $? for details."
              end
              output = File.open("#{tempfilein.path}.dat").read
              puts output
            end
          end
        }
        return TandemRepeatFinderResult.create_from_dat_file(output)
      end
    end
    class TandemRepeatFinderResult < Array
      def self.create_from_dat_file(dat_file_read)
        r = self.new
      end
    end
  end
end
