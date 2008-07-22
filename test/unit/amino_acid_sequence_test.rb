require File.dirname(__FILE__) + '/../test_helper'

class AminoAcidSequenceTest < ActiveSupport::TestCase
  fixtures :sequences
  
  # Replace this with your real tests.
  def test_bl2seq
    aa = AminoAcidSequence.find(1)
    aa2 = AminoAcidSequence.find(2)
    
    b = aa.blastp(aa2)
    assert b
    assert_equal 1, b.iterations[0].hits.length
    assert_equal 5.0e-11, b.iterations[0].hits[0].evalue
  end
end
