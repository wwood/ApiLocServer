# 
# To change this template, choose Tools | Templates
# and open the template in the editor.
 

$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'tm_hmm_wrapper'
require 'rubygems'
require 'bio'
require 'transmembrane'

class TmHmmWrapperTest < Test::Unit::TestCase
  include Transmembrane
  
  def test_parser
    result = TmHmmResult.create_from_short_line('PFA0635c	len=555	ExpAA=0.00	First60=0.00	PredHel=0	Topology=o')
    assert result
    assert_equal false, result.has_domain?
    
    # test a single TMD
    result = TmHmmResult.create_from_short_line('PFA0685c	len=324	ExpAA=20.36	First60=0.00	PredHel=1	Topology=o281-303i')
    assert result
    assert_equal 1, result.transmembrane_domains.length
    assert_equal 281, result.transmembrane_domains[0].start
    assert_equal 303, result.transmembrane_domains[0].stop
    assert_equal OrientedTransmembraneDomain::OUTSIDE_IN,
      result.transmembrane_domains[0].orientation
    assert result.transmembrane_type_1?
    assert_equal false, result.transmembrane_type_2?
    
    # test 2 TMD
    result = TmHmmResult.create_from_short_line('PFA0680c	len=209	ExpAA=43.03	First60=0.02	PredHel=2	Topology=i137-159o164-183i')
    assert result
    assert_equal 2, result.transmembrane_domains.length
    assert_equal 137, result.transmembrane_domains[0].start
    assert_equal 159, result.transmembrane_domains[0].stop
    assert_equal OrientedTransmembraneDomain::INSIDE_OUT,
      result.transmembrane_domains[0].orientation
    assert_equal 164, result.transmembrane_domains[1].start
    assert_equal 183, result.transmembrane_domains[1].stop
    assert_equal OrientedTransmembraneDomain::OUTSIDE_IN,
      result.transmembrane_domains[1].orientation
    assert_equal false, result.transmembrane_type_1?
    assert_equal false, result.transmembrane_type_2?
    
    # test 3 TMD
    result = TmHmmResult.create_from_short_line('PFA0705c	len=282	ExpAA=90.97	First60=22.20	PredHel=4	Topology=i22-44o185-207i212-234o259-281i')
    assert result
    assert_equal 4, result.transmembrane_domains.length
    assert_equal 22, result.transmembrane_domains[0].start
    assert_equal 44, result.transmembrane_domains[0].stop
    assert_equal OrientedTransmembraneDomain::INSIDE_OUT,
      result.transmembrane_domains[0].orientation
    assert_equal 185, result.transmembrane_domains[1].start
    assert_equal 207, result.transmembrane_domains[1].stop
    assert_equal OrientedTransmembraneDomain::OUTSIDE_IN,
      result.transmembrane_domains[1].orientation
    assert_equal 259, result.transmembrane_domains[3].start
    assert_equal 281, result.transmembrane_domains[3].stop
    assert_equal OrientedTransmembraneDomain::OUTSIDE_IN,
      result.transmembrane_domains[3].orientation
    assert_equal false, result.transmembrane_type_1?
    assert_equal false, result.transmembrane_type_2?
  end
  
  def test_wrapper
    prog = TmHmmWrapper.new
    seq = Bio::FlatFile.auto('testFiles/falciparum1.fa').next_entry
    tmp = prog.calculate(seq.seq)
    assert tmp
    assert_equal false, tmp.has_domain?
  end
end
