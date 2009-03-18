require File.dirname(__FILE__) + '/../test_helper'

class SequenceTest < ActiveSupport::TestCase
  def test_at_content
    assert_equal 0.8, CodingRegion.find(2).at_content
  end
end
