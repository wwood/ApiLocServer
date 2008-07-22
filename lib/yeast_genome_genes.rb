
require 'api_db_genes' 

# Yeastgenome gff files are much like apidb gene files, with a few differences
class YeastGenomeGenes < ApiDbGenes
  
  def next_gene
    cur = @next_gff

    if !cur
      return nil
    end
    
    # Ignore the supercontigs at the start of the file
    while ignore_line?(cur)
      @next_gff = read_record
      cur = @next_gff
      if !cur
        return nil
      end
    end
    
    if cur.feature != 'gene' and 
        cur.feature != 'transposable_element_gene' and 
        cur.feature != 'pseudogene'
      raise Exception, "Badly parsed apidb line: #{cur}. Expected gene first."
    end
    
    # save line so can set these values later,
    # i
    gene_line = cur
      
      

    
    # Setup the gene in itself
    gene = setup_gene_from_first_line gene_line
    
    # First CDS
    cur = read_record
    
    if cur.feature != 'CDS'
      # skip rRNA type genes because they are not relevant
      if false
        # skip forward to the next gene
        while cur.feature != 'gene'
          cur = read_record
        end
        @next_gff = cur
        return next_gene
      else
        raise Exception, "Badly parsed apidb line: #{cur}. Expected mRNA next."
      end
    end
    
    if cur.feature != 'CDS'
      raise Exception, "Badly parsed apidb line: #{cur}. Expected CDS next."
    end
    gene.cds = []
    while cur.feature == 'CDS'
      f = Bio::Location.new
      f.from = cur.start
      f.to = cur.end
      gene.cds.push f
        
      cur = read_record
      if !cur
        return nil
      end
    end
      
    
    #ignore whatever comes after that
      
    @next_gff = cur

    return gene
  end
  
  # ignore this line when parsing the file
  def ignore_line?(cur)
    to_ignore = ['chromosome','repeat_region','telomere',
      'binding_site','nucleotide_match','long_terminal_repeat',
      'ARS','region','intron','ncRNA','noncoding_exon','tRNA','snoRNA',
      'centromere', 'LTR_retrotransposon','five_prime_UTR_intron',
      'snRNA','gene_cassette','insertion','rRNA',
      'external_transcribed_spacer_region','internal_transcribed_spacer_region'
      ]
    
    to_ignore.each do |c|
      if cur.feature == c
        return true
      end
    end
    
    return false
  end
  
  private  
  # Given a line describing a gene in an apidb gff file, setup all the
  # stuff associated with the 'gene' line
  def setup_gene_from_first_line(gene_line)
    gene = PositionedGeneWithOntology.new
    gene.start = gene_line.start
    gene.strand = gene_line.strand
    aliai = gene_line.attributes['Alias']
    if aliai
      aliai.chomp!
      gene.alternate_ids = aliai.split ','
    end
    
    
    gene.name = gene_line.attributes['ID']
    gene.seqname = gene_line.seqname
    ids = gene_line.attributes['Ontology_term']
    if ids
      gene.go_identifiers = ids.split ','
    end
    
    return gene
  end
end