# A class to handle parsing of the OrthoMCL fasta definition files
class OrthomclDeflineParser
  # Given an OrthoMCL defline, for instance
  # dre|ENSDARP00000019888 | OG2_70678 | ENSDARG00000001889|ENSF00000000077|hypothetical protein LOC641561 [Source:RefSeq_peptide;Acc:NP_001032649]
  # return an OrthomclDefline object containing the parsed information.
  # The line may have the '>' or not - this method should handle both
  def self.parse_defline(line)
    obj = OrthomclDefline.new
      # return accession, group and annotation for a given defline. E.g.
    matches = line.match(/^>([a-z]+)\|(.+?) \| (.+?) \|(.*)$/)
    if matches.nil?
      raise Exception, "Unable to parse orthomcl defline #{line}!"
    end
    
    obj.gene_id = "#{matches[1]}|#{matches[2]}"
    obj.group_id = matches[3]
    obj.annotation = matches[4].gsub(/^ /,'')
    
    return obj
  end
  class << self
    alias_method :parse, :parse_defline
  end
end

class OrthomclDefline
  attr_accessor :group_id, :gene_id, :annotation
end