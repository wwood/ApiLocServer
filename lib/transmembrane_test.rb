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
  end
end
