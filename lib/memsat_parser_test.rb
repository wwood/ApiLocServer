# 
# To change this template, choose Tools | Templates
# and open the template in the editor.
 

$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'memsat_parser'

class MemsatParserTest < Test::Unit::TestCase
  def test_simple
    protein = MemsatParser.new.parse('/home/ben/phd/transmembrane/no_signalp/memsat5456.memsat')
    assert protein
    assert_equal 2, protein.transmembrane_domains.length
    d1 = protein.transmembrane_domains[0]
    assert_equal 123, d1.start
    assert_equal 142, d1.stop
    d1 = protein.transmembrane_domains[1]
    assert_equal 310, d1.start
    assert_equal 334, d1.stop
  end
  
  def test_single
    protein = MemsatParser.new.parse('/home/ben/phd/transmembrane/no_signalp/memsat4.memsat')
    assert protein
    assert_equal 1, protein.transmembrane_domains.length
    d1 = protein.transmembrane_domains[0]
    assert_equal 328, d1.start
    assert_equal 352, d1.stop
  end
  
  def test_none
     protein = MemsatParser.new.parse('/home/ben/phd/transmembrane/no_signalp/memsat5.memsat')
    assert protein
    assert_equal 0, protein.transmembrane_domains.length
    assert_equal false, protein.has_domain?
  end
end
