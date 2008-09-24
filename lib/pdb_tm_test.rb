# 
# To change this template, choose Tools | Templates
# and open the template in the editor.
 

$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'pdb_tm'

class PdbTmTest < Test::Unit::TestCase
  def test_extract
    pdbtm = Bio::PdbTm::Xml.new(File.open('lib/testFiles/pdbtmalpha.extract.xml').read)
    entries = pdbtm.entries
    assert entries
    assert_kind_of Array, entries
    assert_equal 2, entries.length
    assert_kind_of Bio::PdbTm::Entry, entries[0]
    
    tmds = entries[0].transmembrane_domains
    assert tmds
    assert_kind_of Array, tmds
    assert_equal 23, tmds.length
    
    t = Transmembrane::TransmembraneDomain.new
    t.start = 30
    t.stop = 53
    assert_equal t, tmds[0]

    t.start = 19
    t.stop = 43
    assert_equal t, tmds[22]
  end
end
