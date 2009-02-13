require 'tempfile'

module Bio
  # A wrapper around blastclust. The main advantage of running this wrapped 
  # version over the original is that the output comes back as Bio::Sequence::AA
  # objects, instead of plain identifiers
  class BlastClust
    attr_accessor :sequences
    
    # Given an array of sequence
    def run
      Tempfile.new do |fasta|
        Tempfile.new do |blastclust_output|
          # for each sequence in sequence, rename it, then make
          @sequences.collect do |sequence|
            fasta.puts rename_sequence(sequence)
            fasta.puts sequence.seq
          end
          fasta.flush
      
          system("blastclust -i #{fasta.path} -o #{blastclust_output.path}")
          return create_sequence_clusters_from_new_names(blastclust_output.read.split("\n"))
        end
      end
    end
    
    class SequenceCluster<Array
      
    end
    
    private
    
    def rename_sequence(original_sequence_object)
      @count ||= 0
      @hash ||= {}
      
      new_name = "br_#{@count}"
      @hash[new_name] = original_sequence_object
      
      @count += 1
      return new_name
    end
    
    def create_sequence_clusters_from_new_names(new_name_lines)
      new_name_lines.each do |line|
        
      end
    end
  end
end
