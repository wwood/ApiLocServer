require File.dirname(__FILE__) + '/../test_helper'

class SequenceTest < ActiveSupport::TestCase
  def test_at_content
    assert_equal 0.8, CodingRegion.find(2).at_content
  end
  
  def test_trf
    assert_equal 1, CodingRegion.find(3).transcript_sequence.tandem_repeats.length
  end
end
