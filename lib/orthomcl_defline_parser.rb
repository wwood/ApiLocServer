# A class to handle parsing of the OrthoMCL fasta definition files
class OrthomclDeflineParser
  # Given an OrthoMCL defline, for instance
  # dre|ENSDARP00000019888 | OG2_70678 | ENSDARG00000001889|ENSF00000000077|hypothetical protein LOC641561 [Source:RefSeq_peptide;Acc:NP_001032649]
  # return an OrthomclDefline object containing the parsed information.
  # The line may have the '>' or not - this method should handle both
  def self.parse_defline(line)
    obj = OrthomclDefline.new
    
    # Remove the initial '>' character if given
    line.gsub!(/^>/,'')
    
    splits_space = line.split(' ')
    if splits_space.length < 3
      raise Exception, "Badly handled line because of spaces: #{line}"
    end
    
    obj.gene_id = splits_space[0]
    obj.group_id = splits_space[2]
    obj.annotation = splits_space[4..(splits_space.length)].join(' ')
    
    return obj
  end
end

class OrthomclDefline
  attr_accessor :group_id, :gene_id, :annotation
end