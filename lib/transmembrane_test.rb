# 
# To change this template, choose Tools | Templates
# and open the template in the editor.
 

$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'transmembrane'

module Transmembrane
  class TransmembraneTest < Test::Unit::TestCase
    def test_confidenced_transmembrane_domain
      one = ConfidencedTransmembraneDomain.new
      two = ConfidencedTransmembraneDomain.new
      assert_equal one, two
    end
    
    def test_sequence_offsets
      aaseq = 'AAAAAANG' #8 aa long
      d = TransmembraneDomainDefinition.new
      d.start = 6
      d.stop = 8
      assert_equal 'ANG', d.sequence(aaseq)
      
      assert_equal 'AANG', d.sequence('AAAAAANG', -1, 0)
      assert_equal 'AANG', d.sequence('AAAAAANG', -1, 1) #overhang
      assert_equal 'AAN', d.sequence('AAAAAANG', -1, -1) #overhang over the cterm
      
      d.start = 1
      d.stop = 5
      assert_equal 'AAAAA', d.sequence('AAAAAANG', -2, 0) #overhang over the nterm
      assert_equal 'AAAAAANG', d.sequence('AAAAAANG', -2, 15) #overhang over the nterm and cterm
    end
  end
end
