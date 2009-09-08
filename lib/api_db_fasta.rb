require 'bio'

# Generalised abstract class for parsing fasta files and their names.
# The parse_name method returns a FastaAnnotation (possibly partially filled in)
# that contains the annotation
class FastaParser
  def load(filename)
    @flat = Bio::FlatFile.open(Bio::FastaFormat, filename)
    # return self for convenience
    return self
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


class FastaAnnotation
  attr_accessor :name, :sequence, :annotation, :scaffold, :gene_id
end


class TigrFasta < FastaParser
  def parse_name(definition)
    s = FastaAnnotation.new
    
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


class ApiDbFasta5p4 < FastaParser
  # Given a fasta line definition string, return a parsed FastaAnnotation object
  # with the string_id, annotation and scaffold name in it
  def parse_name(definition)

    s = FastaAnnotation.new
     
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
end

# They changed the naming system from 5.4 to 5.5
class ApiDbFasta5p5 < FastaParser
  #psu|PFC1120c | organism=Plasmodium_falciparum_3D7 | product=var (3D7-varT3-2) | location=MAL3:1027492-1034924(-) | length=2169
  def parse_name(definition)
    s = FastaAnnotation.new
     
    # eg. 
    # >psu|PFC1120c | organism=Plasmodium_falciparum_3D7 | product=var (3D7-varT3-2) | location=MAL3:1027492-1034924(-) | length=2169
    # >gb|PVX_090835 | organism=Plasmodium_vivax_SaI-1 | product=hypothetical protein | location=CM000450:19413-20373(+) | length=961
    # requires 'timid' search for first bits because sometimes the annotation contains a '|' character at the end -> bad!
    matches = definition.match('^psu\|(.+?) \| organism=(\S+?) \| product=(.*?) \| location=(.+?) \| length=(\d+)$')
    if !matches
      matches = definition.match('^gb\|(.+?) \| organism=(\S+?) \| product=(.*?) \| location=(.+?) \| length=(\d+)$')
    end
    if !matches
      raise Exception, "Definition line has unexpected format: #{definition}"
    end
    
    s.name = matches[1]
    s.annotation = matches[3]
    
    matches2 = matches[4].match(/^(.+?)\:/)
    if !matches2
      raise Exception, "Definition line has unexpected scaffold format: #{matches[4]}"
    end
    s.scaffold = matches2[1]
    
    return s
  end
end

class ToxoDbFasta4p3 < FastaParser
  #>Toxoplasma_gondii|TGG_994843|190.m00008|Annotation|Toxoplasma_gondii_TIGR|(protein coding) hypothetical protein
  def parse_name(definition)
    s = FastaAnnotation.new
    
    matches = definition.match(/^Toxoplasma_gondii\|(.+)\|(.+)\|Annotation\|Toxoplasma_gondii_TIGR\|(.+)$/)
    if !matches
      raise Exception, "Definition line has unexpected format: #{definition}"
    end
    
    s.name = matches[2]
    s.annotation = matches[3]
    s.gene_id = matches[1]
    return s
  end
end

class ApiDbVivaxFasta5p5 < FastaParser
  # gb|PVX_086995 | organism=Plasmodium_vivax_SaI-1 | product=uncharacterised trophozoite protein, putative | location=CM000448:1306916-1307575(+) | length=219
  def parse_name(definition)
    s = FastaAnnotation.new
    
    matches = definition.match(/^gb\|(.*?) \| organism=Plasmodium_vivax_SaI-1 \| product=(.*?) \| location=.* \| length=\d+$/)
    if !matches
      raise Exception, "Definition line has unexpected format: #{definition}"
    end
    
    s.name = matches[1]
    s.annotation = matches[2]
    return s
  end
end

# Looks like EuPathDB databases have settled on something like
# >gb|TGME49_000380 | organism=Toxoplasma_gondii_ME49 | product=myb-like DNA binding domain-containing protein | location=TGME49_chrVIII:6835359-6840923(-) | length=1528
# where the species name differs but the rest is mostly constant
class EuPathDb2009 < FastaParser
  attr_accessor :species_name, :sequencing_centre
  
  # The species name is what should show up in the 2nd bracket, so something
  # like 'Toxoplasma_gondii_ME49' for
  # >gb|TGME49_000380 | organism=Toxoplasma_gondii_ME49 | product=myb-like DNA binding domain-containing protein | location=TGME49_chrVIII:6835359-6840923(-) | length=1528
  # for instance
  def initialize(species_name, sequencing_centre='gb')
    @species_name = species_name
    @sequencing_centre = sequencing_centre
  end
  
  def parse_name(definition)
    s = FastaAnnotation.new

    matches = definition.match(/^#{@sequencing_centre}\|(.*?) \| organism=#{@species_name} \| product=(.*?) \| location=(.*) \| length=\d+$/)
    p
    if !matches
      raise ParseException, "Definition line has unexpected format: #{definition}"
    end

    matches2 = matches[3].match(/^(.+?)\:/)
    if !matches2
      raise ParseException, "Definition line has unexpected scaffold format: #{matches[4]}"
    end
    s.scaffold = matches2[1]
    s.name = matches[1]
    s.annotation = matches[2]
    return s
  end
end

class CryptoDbFasta4p0 < FastaParser
  def parse_name(definition)
    s = FastaAnnotation.new

    matches = definition.match(/^gb\|(.*?) \| organism=Cryptosporidium_(.+?) \| product=(.*?) \| location=(.*) \| length=\d+$/)
    if !matches
      raise Exception, "Definition line has unexpected format: #{definition}"
    end

    matches2 = matches[4].match(/^(.+?)\:/)
    if !matches2
      raise Exception, "Definition line has unexpected scaffold format: #{matches[4]}"
    end
    s.scaffold = matches2[1]
    s.name = matches[1]
    s.annotation = matches[3]
    return s
  end
end

class ParseException < Exception; end