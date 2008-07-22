# 
# To change this template, choose Tools | Templates
# and open the template in the editor.
 

$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'gff3_genes'

class Gff3GenesTest < Test::Unit::TestCase
  # elegans is a fully fledged GFF3, so presumably if it works here it'll work on anything
  def test_real
    records = GFF3ParserFixed.new('II	history	intron	13604559	13604602	.	+	.	Name=Y48E1B.13:wp63;confirmed_unknown=1').records
    assert_equal 1, records.length
    r = records[0]
    assert_kind_of Hash, r.attributes
    hash = {"Name"=>"Y48E1B.13:wp63", "confirmed_unknown"=>"1"}
    assert_equal hash, r.attributes
    
    lines = [
      'II	history	intron	13604559	13604602	.	+	.	',
      'II	mSplicer_orf	CDS	13604603	13604839	.	+	.	Parent=CDS:mSplicer_orf:msp-Y48E1B.13a'
    ]
    records = GFF3ParserFixed.new(lines.join("\n")).records
    assert_equal 2, records.length
    
    r = records[0]
    assert_nil r.attributes
    #    assert_kind_of Hash, r.attributes
    #    hash = {}
    #    assert_equal hash, r.attributes
    
    r = records[1]
    assert_kind_of Hash, r.attributes
    hash = {"Parent"=>"CDS:mSplicer_orf:msp-Y48E1B.13a"}
    assert_equal hash, r.attributes
    
    # test multiple lines
    
    
    #    g = genes.next_gene
    #    assert_equal 'PF11_0521', g.name
    #    assert_equal 'apidb|MAL11', g.seqname
    #    assert_equal 2, g.cds.length
    #    assert_equal 2, g.exons.length
    #    assert_equal '2025814', g.cds_start
    #    assert_equal '2035883', g.cds_end
    #    count = 1
    #    
    #    last = nil
    #    while g = genes.next_gene
    #      last = g
    #      count += 1
    #    end
    #    g = last
    #    
    #    assert_equal 5000, count
    #    
    #    # make sure the last gene is correct
    #    assert_equal 'PF11_0521', g.name
    #    assert_equal 'apidb|MAL11', g.seqname
    #    assert_equal 2, g.cds.length
    #    assert_equal 2, g.exons.length
    #    assert_equal '2025814', g.cds_start
    #    assert_equal '2035883', g.cds_end
  end
  
  
  
  def test_light_next_record
    # test one line, simple
    # II	history	intron	13604559	13604602	.	+	.	Name=Y48E1B.13:wp63;confirmed_unknown=1
    parser = GFF3ParserLight.new(File.open('testFiles/oneFeature.gff3'))
    count = 0
    parser.each_feature('intron') do |r|
      assert r
      assert_equal '13604602', r.end
      assert_kind_of Hash, r.attributes
      hash = {"Name"=>"Y48E1B.13:wp63", "confirmed_unknown"=>"1"}
      assert_equal hash, r.attributes
      count += 1
    end
    assert_equal 1, count
    
    # test 2 lines. skip the first one
    # II	history	intron	13604559	13604602	.	+	.	
    #II	mSplicer_orf	CDS	13604603	13604839	.	+	.	Parent=CDS:mSplicer_orf:msp-Y48E1B.13a
    parser = GFF3ParserLight.new(File.open('testFiles/twoFeatures.gff3'))
    count = 0
    parser.each_feature('CDS') do |r|
      assert r
      assert_equal '13604603', r.start
      count += 1
    end
    assert_equal 1, count
    
    
    # multiple returns
    #II	history	intron	13604559	13604602	.	+	.	Name=Y48E1B.13:wp63;confirmed_unknown=1
    #II	history	intron	13604559	13604602	.	+	.	Name=Y48E1B.13:wp63;confirmed_unknown=1
    #II	history	intron	13604559	13604602	.	+	.	Name=Y48E1B.13:wp63;confirmed_unknown=1
    #II	history	intron	13604559	13604602	.	+	.	Name=Y48E1B.13:wp63;confirmed_unknown=1
    #II	mSplicer_orf	CDS	13604603	13604839	.	+	.	Parent=CDS:mSplicer_orf:msp-Y48E1B.13a
    parser = GFF3ParserLight.new(File.open('testFiles/fiveFeatures.gff3'))
    count = 0
    parser.each_feature('intron') do |r|
      assert r
      assert_equal '13604559', r.start
      assert_equal 'Y48E1B.13:wp63', r.attributes['Name']
      count += 1
    end
    assert_equal 4, count
  end
end
