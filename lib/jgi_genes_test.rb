# 
# To change this template, choose Tools | Templates
# and open the template in the editor.
 

$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'jgi_genes'

class JgiGenesTest < Test::Unit::TestCase
  #  def test_read_gff_gene
  ##    jgi = JgiGenesGff.new('testFiles/test.gff')
  #    
  ##    gene = jgi.next_gene
  ##    assert gene
  ##    assert gene.exons
  ##    assert_equal(2, gene.exons.length)
  #
  #    jgi = JgiGenesGff.new('testFiles/test3genes.gff')
  #    gene = jgi.next_gene
  #    assert gene
  #    assert_equal 'fgenesh2_pg.scaffold_1000001', gene.name
  #    assert gene.exons
  #    assert gene.cds
  #    assert_equal(2, gene.exons.length)
  #    assert_equal(2, gene.cds.length)
  #    
  #    gene = jgi.next_gene
  #    assert gene
  #    assert_equal 'fgenesh2_pg.scaffold_1000002', gene.name
  #    assert gene.exons
  #    assert gene.cds
  #    assert_equal(1, gene.exons.length)
  #    assert_equal(1, gene.cds.length)
  #        
  #    gene = jgi.next_gene
  #    assert_equal 'e_gw.1.270.1', gene.name
  #    assert gene
  #    assert gene.exons
  #    assert gene.cds
  #    assert_equal(3, gene.exons.length)
  #    assert_equal(3, gene.cds.length)
  #  end
  
  
  def test_jgi_gff_parser
    jgi = JgiGffRecord.new("scaffold_1\tJGI\texon\t12\t12639\t.\t-\t.\tname \"fgenesh2_pg.scaffold_1000001\"; transcriptId 63195
")

    assert_equal 'scaffold_1', jgi.seqname
    assert_equal 'JGI', jgi.source
    assert_equal 'exon', jgi.feature
    assert_equal '12', jgi.start
    assert jgi.attributes
    assert_equal 2, jgi.attributes.keys.length
    assert jgi.attributes['name']
    assert_equal 'fgenesh2_pg.scaffold_1000001', jgi.attributes['name']
    assert_equal '63195', jgi.attributes['transcriptId']
    
    
    #test with no comments
    jgi = JgiGffRecord.new("scaffold_1\tJGI\texon\t12\t12639\t.\t-\t.")

    assert_equal 'scaffold_1', jgi.seqname
    assert_equal 'JGI', jgi.source
    assert_equal 'exon', jgi.feature
    assert_equal '12', jgi.start
    assert jgi.attributes
    assert_equal 0, jgi.attributes.keys.length
  end
  
  def test_distance_iterator
    jgi = JgiGenesGff.new('testFiles/test3genes.gff')
    
    iter = jgi.distance_iterator
    assert iter.has_next_distance
    d = iter.next_distance
    assert_equal 7136, d
    pid = iter.next_gene
#    assert_equal 63195, pid.protein_id
    assert iter.has_next_distance
    d = iter.next_distance
    assert_equal 12591, d
    assert iter.has_next_distance
    d = iter.next_distance
    assert_equal 12591, d
    pid = iter.next_gene
    assert_equal 198865, pid.protein_id
    assert_equal false, iter.has_next_distance
  end
  

  def test_distance_iter_change_scaffold
    jgi = JgiGenesGff.new('testFiles/test4genesChangeScaffold.gff')
    
    iter = jgi.distance_iterator
    assert iter.has_next_distance
    assert_equal nil, iter.next_distance
    assert iter.has_next_distance
    assert_equal 12591, iter.next_distance
    assert iter.has_next_distance
    assert_equal 12591, iter.next_distance
    assert iter.has_next_distance
    assert_equal nil, iter.next_distance
    assert_equal false, iter.has_next_distance
  end
end
