
class GMARS
  def initialize(alphabet = 'ACDEFGHIKLMNPQRSTVWY', ignoring_alphabet = 'X')
    @protein_ids = alphabet.split('')
    @protein_id_hash = {}
    @protein_ids.each_with_index do |letter, index|
      @protein_id_hash[letter] = index
    end
    
    @ignoring_alphabet = ignoring_alphabet
  end
  
  # Given a protein sequence, return an array of compositions
  def gmars_gapped_vector(sequence, max_gap)
    
    # a multidimensional array of gaps/alphabet_first/alphabet_second
    nodes = []

    # Initialise the array members with nodes
    (0..max_gap).each do |gap|
      nodes[gap] = []
      @protein_ids.each_with_index do |letter1, first_index|
        nodes[gap][first_index] = []
        
        @protein_ids.each_with_index do |letter2, alphabet_index|
          n = Node.new
          matches = sequence.scan(/#{letter1}/) # How many times does it match in total?
          n.total = matches.empty? ? 0 : matches.length
          n.count = 0
          nodes[gap][first_index][alphabet_index] = n
        end
      end
    end
    
    sequence_array = sequence.split('')

    # count each of positives
    sequence_array.each_with_index do |first_letter, first_sequence_index|
      first_alphabet_index = @protein_id_hash[first_letter]
      (0..max_gap).each do |gap|
        if first_sequence_index + gap + 1 < sequence.length # ignore if not at the end of the sequence
                    
          
          
          # increment the winning count
          second_letter = sequence_array[first_sequence_index+gap+1]
          second_alphabet_index = @protein_id_hash[second_letter]
          
          if !second_alphabet_index or !first_alphabet_index
            next if @ignoring_alphabet.match(/[#{second_letter}#{first_letter}]/) # ignore certain letters
            # otherwise something has gone astray, so forget about it
            raise Exception, "Letter '#{second_letter}' is not part of the specified alphabet"
          end
          node = nodes[gap][first_alphabet_index][second_alphabet_index]
          node.count += 1
        end
      end
    end

    # return a flat array of normalised elements, returning 0.0 when the letter does not appear in the alphabet
    nodes.flatten.collect {|node|
      node.total > 0 ? node.count.to_f / node.total.to_f : 0.0
    }
  end
  
  class Node
    attr_accessor :count, :total
  end
end