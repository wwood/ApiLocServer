# 
# To change this template, choose Tools | Templates
# and open the template in the editor.
 

$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'top_db_xml'

module Bio
  module TopDb
    class TopDbTest < Test::Unit::TestCase
      def test_simple
        t = TopDbXml.new(File.open('lib/testFiles/AB00003.xml').read)
        tmds = t.transmembrane_domains
        assert tmds
        assert_kind_of Array, tmds
        assert_equal 1, tmds.length
        
        expected = Transmembrane::ConfidencedTransmembraneDomain.new
        expected.confidence = 100
        expected.start = 693
        expected.stop = 707
        assert_equal expected, tmds[0]
      end
      
      def test_multiple
        t = TopDbXml.new(File.open('lib/testFiles/AP01202.xml').read)
        tmds = t.transmembrane_domains
        assert tmds
        assert_kind_of Array, tmds
        assert_equal 6, tmds.length
        
        expected = Transmembrane::ConfidencedTransmembraneDomain.new
        expected.confidence = 100
        expected.start = 22
        expected.stop = 45
        assert_equal expected, tmds[0]
        
        expected.confidence = 100
        expected.start = 59
        expected.stop = 82
        assert_equal expected, tmds[1]

        expected.confidence = 100
        expected.start = 198
        expected.stop = 221
        assert_equal expected, tmds[6]
      end
    end
  end
end
