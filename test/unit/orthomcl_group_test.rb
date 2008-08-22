require File.dirname(__FILE__) + '/../test_helper'

class OrthomclGroupTest < ActiveSupport::TestCase
  def test_all_overlapping_groups_single_return
    groups = OrthomclGroup.all_overlapping_groups(['cel','dme'])
    assert_equal 1, groups.length, groups.inspect
    assert_equal 1, groups[0].id
    assert_kind_of OrthomclGroup, groups[0]
  end
  
  def test_all_overlapping_groups_multiple_return
    assert OrthomclGene.first(:conditions => "orthomcl_name like 'dme%' and id=5" )
    assert OrthomclGene.count >= 7
    groups = OrthomclGroup.all_overlapping_groups(['dme'])
    assert_equal 2, groups.length, groups.inspect
    assert_equal 1, groups[1].id #order unimportant
    assert_equal 2, groups[0].id
    assert_kind_of OrthomclGroup, groups[0]
  end
  
  def test_empty_all_overlapping
    stupid = OrthomclGroup.all_overlapping_groups([])
    assert_equal 2, stupid.length, stupid
  end
end
