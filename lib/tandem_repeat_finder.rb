require 'tempfile'
require 'tempdir'

module Bio
  class TandemRepeatFinder
    class Wrapper
      # Run TRF (Tandem Repeat Finder) and return a TandemRepeatFinder::Result
      # object on the (purely sequence, not fasta) string
      def run(sequence)
        output = nil

        # Execute the program in a temporary directory so that
        # the .dat file trf spits out is temporary
          
        d = Tempdir.new('trf')
        Dir.chdir(d) do
          Tempfile.open('trfin', d) do |tempfilein|
            # Write a fasta to the tempfile
            tempfilein.puts '>wrapperSeq'
            tempfilein.puts "#{sequence.to_s}"
            tempfilein.close #required. Maybe because it doesn't flush otherwise?

            result = system("trf #{tempfilein.path} 2 7 7 80 10 50 500 -h >/dev/null 2>/dev/null")
            #            result = system("trf #{tempfilein.path} 2 7 7 80 10 50 500 -h")
            
            # trf exits with status 1 so can't use this to tell
            #            if !result
            #                            raise Exception, "Running tandem repeat finder program failed. $? is '#{$?.inspect}'"
            #            end
            output = File.open("#{tempfilein.path}.2.7.7.80.10.50.500.dat").read
          end
        end
        return Result.create_from_dat_file(output)
      end
    end
    
    class Result < Array
      def self.create_from_dat_file(dat_file_read)
        splits = dat_file_read.split("\n")

        r = self.new

        if splits.length > 15 #if any tandem repeats were found
          splits[(15..splits.length)].each do |result_line|
            s = result_line.split(' ')

            repeat = TandemRepeat.new
            repeat.start = s[0].to_i
            repeat.stop = s[1].to_i
            repeat.copy_number = s[3].to_f

            r.push repeat
          end
        end

        r
      end

      # the total number of nucleotides covered. Some repeats can be overlapping
      # and this is accounted for
      def length_covered
        nukes = []
        each do |repeat|
          (repeat.start..repeat.stop).each do |position|
            nukes.push position
          end
        end
        return nukes.uniq.length
      end
    end

    class TandemRepeat
      attr_accessor :start, :stop, :copy_number
    end
  end
end
