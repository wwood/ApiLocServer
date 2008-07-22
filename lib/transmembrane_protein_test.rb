# 
# To change this template, choose Tools | Templates
# and open the template in the editor.
 

$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'transmembrane'

class TransmembraneProteinTest < Test::Unit::TestCase
  def test_simple
    protein = TransmembraneProtein.new
    tmd = TransmembraneDomain.new
    tmd.start = 8
    tmd.stop = 9
    protein.push tmd
    
    tmd = TransmembraneDomain.new
    tmd.start = 8
    tmd.stop = 10
    protein.push tmd
    
    assert_equal 2, protein.minimum_length
    assert_equal 2.5, protein.average_length
  end
  
  def test_empty
    protein = TransmembraneProtein.new
    assert protein.transmembrane_domains.empty?
    assert_equal false, protein.has_domain?
  end
end
