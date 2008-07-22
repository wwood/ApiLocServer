require 'rubygems'
gem 'bio'
require 'bio'

class ApiDbFasta
  def load(filename)
    @flat = Bio::FlatFile.open(Bio::FastaFormat, filename)
    # return self for convenience
    return self
  end
  
  # Given a fasta line definition string, return a parsed ApiDbFastaSequence object
  # with the string_id, annotation and scaffold name in it
  def parse_name(definition)

    s = ApiDbFastaSequence.new
     
    # eg. 
    # >Plasmodium_falciparum_3D7|MAL8|PF08_0142|Annotation|Plasmodium_falciparum_Sanger_Stanford_TIGR|(protein coding) erythrocyte membrane protein 1 (PfEMP1)
    # requires 'timid' search for first bits because sometimes the annotation contains a '|' character at the end -> bad!
    matches = definition.match('^(.+?)\|(.+?)\|(.+?)\|(.+?)\|(.+?)\|(.+)$')
    if !matches
      raise Exception, "Definition line has unexpected format: #{definition}"
    end
    
    s.name = matches[3]
    s.annotation = matches[6]
    s.scaffold = matches[2]
    
    return s
  end
  
  def next_entry
    return nil if !@flat
    n = @flat.next_entry
    return nil if !n
    
    s = parse_name(n.definition)
    s.sequence = n.seq
    return s
  end
end


class ApiDbFastaSequence
  attr_accessor :name, :sequence, :annotation, :scaffold
end


class TigrFasta < ApiDbFasta
  def parse_name(definition)
    s = ApiDbFastaSequence.new
    
    matches = definition.match('^(.+?)\|(.*?)\|(.*?)\|(.*?)\|(.+?)\|(.+?)\|(.+?)\|(.+)$')
    if !matches
      raise Exception, "Definition line has unexpected format: #{definition}"
    end
    
    s.name = matches[1].strip
    if matches[2] != ''
      s.name = matches[2].strip
    end
    s.annotation = matches[4]
    s.scaffold = matches[2]
    
    return s
  end
end
