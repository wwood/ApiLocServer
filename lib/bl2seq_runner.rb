require 'tempfile'
require 'rubygems'
require 'bio'

# Given 2 Bio:seq objects, blast them against each other and return the result.
module Bio
  class Blast

    class Bl2seq
      class Runner
        # Run a Bio::Seq object against another. Assumes bl2seq is working correctly
        def bl2seq(seq1, seq2, options = {})
          optional_arguments = ''
          
          unless options.nil?
            if e = options[:evalue]
              optional_arguments += "-e #{e}"
            end
          end
          
          Tempfile.open('rubybl2seq') { |t1|  
            t1.puts seq1.output(:fasta)
            t1.close
            
            Tempfile.open('rubybl2seq') { |t2|  
              t2.puts seq2.output(:fasta)
              t2.close
              
              Tempfile.open('rubybl2seqout') { |t3|  

                # Run the bl2seq. Assume protein blast for the moment
                cmd = "bl2seq #{optional_arguments} -i #{t1.path} -j #{t2.path} -p blastp -o #{t3.path}"
                ret = system cmd
                
              
                if !ret #Something went wrong
                  raise Exception, "Failed to run bl2seq: #{$?}"
                else
                  # Create the report from the output file
                  str = File.open(t3.path).read
                  
                  return Bio::Blast::Bl2seq::Report.new(str)
                end
              }
            }
          }
        end
      end
    end
  end
end