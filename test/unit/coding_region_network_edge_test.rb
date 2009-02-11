#require 'test_helper'
require File.dirname(__FILE__) + '/../test_helper'

class CodingRegionNetworkEdgeTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  def test_simple
    n = Network.create!(
      :name => 'dummy'
    )
    edge = CodingRegionNetworkEdge.create!(
      :coding_region_id_first => CodingRegion.first.id,
      :coding_region_id_second => CodingRegion.last.id,
      :network_id => n.id
    )
    assert edge
    assert_equal CodingRegion.first, edge.coding_region_1
    assert_equal CodingRegion.last, edge.coding_region_2
  end

  def test_named_scope
    n = Network.create!(
      :name => 'dummy'
    )
    assert_not_equal CodingRegion.first(:order => 'id').id, CodingRegion.last(:order => 'id').id #so we are on the same page
    edge = CodingRegionNetworkEdge.create!(
      :coding_region_id_first => CodingRegion.first(:order => 'id').id,
      :coding_region_id_second => CodingRegion.last(:order => 'id').id,
      :network_id => n.id
    )
    assert edge
  
    assert CodingRegionNetworkEdge.coding_region_ids(CodingRegion.first(:order => 'id').id, CodingRegion.last(:order => 'id').id).first
    assert CodingRegionNetworkEdge.coding_region_ids(CodingRegion.last(:order => 'id').id, CodingRegion.first(:order => 'id').id).first
    assert_nil CodingRegionNetworkEdge.coding_region_ids(CodingRegion.last(:order => 'id').id, CodingRegion.last(:order => 'id').id).first
  end
  
  def test_network_name_named_scope
    n = Network.create!(
      :name => 'dummy'
    )
    edge = CodingRegionNetworkEdge.create!(
      :coding_region_id_first => CodingRegion.first.id,
      :coding_region_id_second => CodingRegion.last.id,
      :network_id => n.id
    )
    assert edge
    assert_equal 'dummy', edge.network.name
    assert_equal CodingRegion.first.id, edge.coding_region_id_first
    assert_equal CodingRegion.last.id, edge.coding_region_id_second
    
    assert CodingRegionNetworkEdge.network_name('dummy').coding_region_ids(CodingRegion.first.id, CodingRegion.last.id).first
    assert_nil CodingRegionNetworkEdge.network_name('rubbish').coding_region_ids(CodingRegion.last.id, CodingRegion.first.id).first
  end
  
  def test_wormnet_named_scope
    n = Network.find_or_create_by_name(
      Network::WORMNET_NAME
    )
    edge = CodingRegionNetworkEdge.create!(
      :coding_region_id_first => CodingRegion.first.id,
      :coding_region_id_second => CodingRegion.last.id,
      :network_id => n.id
    )
    assert edge
    assert_equal CodingRegion.first.id, edge.coding_region_id_first
    assert_equal CodingRegion.last.id, edge.coding_region_id_second
    
    assert CodingRegionNetworkEdge.wormnet.coding_region_ids(CodingRegion.first.id, CodingRegion.last.id).first
    assert_nil CodingRegionNetworkEdge.network_name('nothing').coding_region_ids(CodingRegion.last.id, CodingRegion.first.id).first
  end
end
