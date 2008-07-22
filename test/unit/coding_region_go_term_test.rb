require File.dirname(__FILE__) + '/../test_helper'

class CodingRegionGoTermTest < ActiveSupport::TestCase
  fixtures :go_terms, :coding_regions, :coding_region_go_terms
  
  def test_simple
    code = CodingRegion.find(1)
    assert code.go_terms
    assert_equal 2, code.go_terms.length
  end
end
