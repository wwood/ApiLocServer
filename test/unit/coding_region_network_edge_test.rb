#require 'test_helper'
require File.dirname(__FILE__) + '/../test_helper'

class CodingRegionNetworkEdgeTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  def test_simple
    n = Network.create!(
      :name => 'dummy'
    )
    edge = CodingRegionNetworkEdge.create!(
      :coding_region_id_1 => CodingRegion.first,
      :coding_region_id_2 => CodingRegion.last,
      :network_id => n.id
    )
    assert edge
    assert_equal CodingRegion.first, edge.coding_region_1
    assert_equal CodingRegion.last, edge.coding_region_2
  end
end
