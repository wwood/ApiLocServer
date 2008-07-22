# 
# To change this template, choose Tools | Templates
# and open the template in the editor.
 

$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'yeast_genome_genes'

class YeastGenomeGenesTest < Test::Unit::TestCase
  def test_yeast_file
    genes = YeastGenomeGenes.new(
      "#{ENV['HOME']}/phd/data/yeast/yeastgenome/20080321/saccharomyces_cerevisiae.gff")
    
    g = genes.next_gene
    assert_equal 'YAL069W', g.name
    assert_equal 'chrI', g.seqname
    assert_equal 1, g.cds.length
    assert_nil g.exons
    assert_equal '335', g.cds_start
    assert_equal '649', g.cds_end   
    assert_equal ['GO:0003674','GO:0005575','GO:0008150'],
      g.go_identifiers
    assert_nil g.alternate_ids
    
    g = genes.next_gene
    assert_equal 'YAL068W-A', g.name
    assert_equal 'chrI', g.seqname
    assert_equal 1, g.cds.length
    assert_nil g.exons
    assert_equal '538', g.cds_start
    assert_equal '792', g.cds_end   
    assert_equal ['GO:0003674','GO:0005575','GO:0008150'].sort,
      g.go_identifiers
    assert_nil g.alternate_ids
    
    g = genes.next_gene
    assert_equal 'YAL068C', g.name
    assert_equal 'chrI', g.seqname
    assert_equal 1, g.cds.length
    assert_nil g.exons
    assert_equal '1807', g.cds_start
    assert_equal '2169', g.cds_end   
    assert_equal ['GO:0003674','GO:0005575','GO:0045944','GO:0030437'].sort,
      g.go_identifiers
    assert_equal ['PAU8'], g.alternate_ids
    
    
  end
  
  #  $ awk -F"        " '{print $3}' ~/phd/data/yeast/yeastgenome/20080321/saccharomyces_cerevisiae.gff |grep gene  |sort |uniq -c
  #   6608 gene
  #      3 gene_cassette
  #     21 pseudogene
  #     89 transposable_element_gene

  def test_correct_count
    genes = YeastGenomeGenes.new(
      "#{ENV['HOME']}/phd/data/yeast/yeastgenome/20080321/saccharomyces_cerevisiae.gff")
    
    count = 0
    gene = nil
    
    while(gene = genes.next_gene)
      assert gene
      assert gene.seqname
      assert gene.cds
      if gene.cds.length < 1
        raise Exception, "Strange gene: #{gene}"
      end
      count = count+1
    end
    
    assert_equal 6608+21+89, count 
  end
end
