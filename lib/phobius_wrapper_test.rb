# 
# To change this template, choose Tools | Templates
# and open the template in the editor.
 

$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'phobius_wrapper'
require 'rubygems'
gem 'bio'
require 'bio'

class PhobiusWrapperTest < Test::Unit::TestCase
  def test_parser
    result = PhobiusResult.create_from_short_line('Plasmodium_falciparum_3D7|MAL7|PF07_0033|Annotation|Plasmodium_falciparum_Sanger_Stanford_TIGR|(protein  0  0  o')
    assert result
    assert_equal false, result.has_domain?
    
    # test a single TMD
    result = PhobiusResult.create_from_short_line('Plasmodium_falciparum_3D7|MAL8|PF08_0140|Annotation|Plasmodium_falciparum_Sanger_Stanford_TIGR|(protein  1  0  o2523-2544i')
    assert result
    assert_equal 1, result.transmembrane_domains.length
    assert_equal 2523, result.transmembrane_domains[0].start
    assert_equal 2544, result.transmembrane_domains[0].stop
    
    # test 10 TMD (PfCRT)
    result = PhobiusResult.create_from_short_line('Plasmodium_falciparum_3D7|MAL7|MAL7P1.27|Annotation|Plasmodium_falciparum_Sanger_Stanford_TIGR|(protein 10  0 i59-77o97-114i126-149o155-175i182-199o211-230i242-264o315-337i344-362o374-394i')
    assert result
    assert_equal 10, result.transmembrane_domains.length
    assert_equal 59, result.transmembrane_domains[0].start
    assert_equal 77, result.transmembrane_domains[0].stop
    assert_equal 97, result.transmembrane_domains[1].start
    assert_equal 114, result.transmembrane_domains[1].stop
  end
  
  def test_wrapper
    prog = PhobiusWrapper.new
    seq = Bio::FlatFile.auto('lib/testFiles/falciparum1.fa').next_entry
    result = prog.calculate(seq.seq)
    assert result
    assert_equal 1, result.transmembrane_domains.length
    assert_equal 1646, result.transmembrane_domains[0].start
  end
end
