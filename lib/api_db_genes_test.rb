# 
# To change this template, choose Tools | Templates
# and open the template in the editor.
 

$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'api_db_genes'
require 'bio'

class ApiDbGenesTest < Test::Unit::TestCase
  def test_foo
    genes = ApiDbGenes.new('lib/testFiles/apiDbTest.gff')
    
    gene = genes.next_gene
    
    assert gene
    assert_equal 1, gene.cds.length
    assert_equal '-', gene.strand
    assert_equal '734', gene.cds_start
    assert_equal '1573', gene.cds_end
    assert_equal 1, gene.exons.length
    assert_nil gene.go_identifiers
    assert_equal 'coxIII', gene.name
    assert_equal 'apidb|NC_002375', gene.seqname
    assert_equal ['PlfaoMp1'], gene.alternate_ids
    assert_equal 'putative cytochrome oxidase III', gene.description
    
    gene = genes.next_gene
    assert_nil gene.alternate_ids
    
    gene = genes.next_gene
    gene = genes.next_gene
    assert_equal 'PFA0005w', gene.name
    assert_equal 2, gene.cds.length
    assert_equal '+', gene.strand
    assert_equal '29733', gene.cds_start
    assert_equal '37349', gene.cds_end
    assert_equal 2, gene.exons.length
    assert gene.go_identifiers
    assert_equal ['GO:0009405','GO:0016337','GO:0020013','GO:0020033',
      'GO:0020035','GO:0016021','GO:0020002','GO:0020030','GO:0004872',
      'GO:0005539','GO:0050839'].sort,
      gene.go_identifiers.sort
    assert_equal 'PFA0005w', gene.name
    assert_equal 'apidb|MAL1', gene.seqname
    assert_equal ['MAL1P4.01','bentest'], gene.alternate_ids
    assert_equal 'erythrocyte membrane protein 1 (PfEMP1)', gene.description
    
    genes.next_gene
    genes.next_gene
    assert_nil genes.next_gene
  end
  
  #  def test_real_file
  #    genes = ApiDbGenes.new('/home/uyen/phd/data/falciparum/genome/plasmodb/5.4/Pfalciparum_3D7_plasmoDB-5.4.gff')
  #    count = 0
  #    while genes.next_gene
  #      count += 1
  #    end
  #    p count
  #  end
  
  
  def test_distances
    genes = ApiDbGenes.new('lib/testFiles/apiDbTest.gff')
    
    iter = genes.distance_iterator
    assert iter.has_next_distance
    d = iter.next_distance
      
    assert_equal 1933-1573, d
    d = iter.next_distance
    assert_equal 1933-1573, d
    d = iter.next_distance
    d = iter.next_distance
    
    # different scaffolds
    assert_nil d
    d = iter.next_distance
    assert_equal 50586-40146, d
    d = iter.next_distance
    assert_equal 50586-40146, d
    
    assert_equal false, iter.has_next_distance
  end
  
  def test_uniq_go_identifiers
    gene = PositionedGeneWithOntology.new
    assert_nil gene.go_identifiers
    
    gene.go_identifiers = ['GO:001']
    assert_equal ['GO:001'], gene.go_identifiers
    
    gene.go_identifiers = ['GO:001','GO:001']
    assert_equal ['GO:001'], gene.go_identifiers
    
    #out of order
    gene.go_identifiers = ['GO:002','GO:001','GO:002']
    assert_equal ['GO:001','GO:002'], gene.go_identifiers
  end
  
  def test_uniq_go_in_gff
    genes = ApiDbGenes.new('lib/testFiles/goTermMultiples.gff')
    g = genes.next_gene
    assert g
    
    assert_equal ['GO:0004840','GO:0004842','GO:0005575','GO:0006464','GO:0006512'],
      g.go_identifiers
    
  end
  
  def test_possible_bug
    genes = ApiDbGenes.new('lib/testFiles/apiDbTestBug.gff')
    
    g = genes.next_gene
    assert_equal 'PF11_0521', g.name
    assert_equal 'apidb|MAL11', g.seqname
    assert_equal 2, g.cds.length
    assert_equal 2, g.exons.length
    assert_equal '2025814', g.cds_start
    assert_equal '2035883', g.cds_end
      
    assert_nil genes.next_gene
  end
  
  # Unfixed bug as at 21 Apr 2008. Error comes out on the cmd line
  # and there isn't anything wrong with the data as it is uploaded
  def test_bug2
    puts
    puts
    puts "MEMEME"
    genes = ApiDbGenes.new('lib/testFiles/apiDbTestBug2.gff')
    assert_nil genes.next_gene
  end
  
  def test_ignore_line?
    gff = Bio::GFF::Record.new('')
    api = ApiDbGenes.new('lib/testFiles/apiDbTestBug2.gff')
    gff.feature = 'supercontig'
    assert api.ignore_line?(gff)
    
    gff.feature = 'blah'
    assert_equal false, api.ignore_line?(gff)
    
    gff.feature = 'introgressed_chromosome_region45'
    assert_equal false, api.ignore_line?(gff)
    
    gff.feature = 'introgressed_chromosome_region'
    assert api.ignore_line?(gff)
  end
  
  def test_ignore_record?
    gff = Bio::GFF::Record.new('')
    api = ApiDbGenes.new('lib/testFiles/apiDbTestBug2.gff')
    
    [nil, 'MAL2', 'apidb|API_IRAB'].each do |bad|
      gff.seqname = bad
      assert api.ignore_record?(gff)
    end
    
    gff.seqname = 'apidb|MAL3'
    assert_equal false, api.ignore_record?(gff)
  end

end
