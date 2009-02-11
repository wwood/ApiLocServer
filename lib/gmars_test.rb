# Author: Ben J Woodcroft <b.woodcroft somewhere near pgrad.unimelb.edu.au>
# Date Created: 31 Oct 2008
# Last Modified: 4 Nov 2008 

$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'gmars'

require 'rubygems'
require 'reach'

class GmarsTest < Test::Unit::TestCase
  def setup
    @gmars = GMARS.new('AB')
  end
  
  def test_no_gap
    assert_equal [0.5, 0.0, 0.0, 0.0], @gmars.gmars_gapped_vector('AA', 0).reach.normalised_value.retract
    assert_equal [2.0/3.0, 0.0, 0.0, 0.0], @gmars.gmars_gapped_vector('AAA', 0).reach.normalised_value.retract
  end
  
  def test_no_gap_two_letters
    assert_equal [0.0, 1.0, 0.0, 0.0], @gmars.gmars_gapped_vector('AB', 0).reach.normalised_value.retract
    assert_equal [0.0, 0.5, 1.0, 0.0], @gmars.gmars_gapped_vector('ABA', 0).reach.normalised_value.retract
  end
  
  def test_one_gap
    assert_equal [0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0], @gmars.gmars_gapped_vector('AB', 1).reach.normalised_value.retract
    assert_equal [0.5, 0.25, 1.0, 0.0, 0.5, 0.0, 1.0, 0.0], @gmars.gmars_gapped_vector('ABAAA', 1).reach.normalised_value.retract
  end
  
  def test_unexpected_amino_acid
    assert_equal [0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0], @gmars.gmars_gapped_vector('ABX', 1).reach.normalised_value.retract
  end
  
  def test_named_node
    assert_equal ['gMARS A A gap 0', 'gMARS A B gap 0', 'gMARS B A gap 0', 'gMARS B B gap 0'], @gmars.gmars_gapped_vector('AA', 0).reach.name.retract
    assert_equal [
      'gMARS A A gap 0', 'gMARS A B gap 0', 'gMARS B A gap 0', 'gMARS B B gap 0',
      'gMARS A A gap 1', 'gMARS A B gap 1', 'gMARS B A gap 1', 'gMARS B B gap 1'
    ], @gmars.gmars_gapped_vector('AA', 1).reach.name.retract
  end
end
