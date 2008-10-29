require File.dirname(__FILE__) + '/../test_helper'

class OrthomclGroupTest < ActiveSupport::TestCase
  def test_all_overlapping_groups_single_return
    groups = OrthomclGroup.all_overlapping_groups(['cel','dme'])
    assert_equal 1, groups.length, groups.inspect
    assert_equal 1, groups[0].id
    assert_kind_of OrthomclGroup, groups[0]
  end
  
  def test_all_overlapping_groups_multiple_return
    # I had stupid problems with this, so there's some extra stuff to test fixtures were loaded correctly
    assert OrthomclGene.first(:conditions => "orthomcl_name like 'dme%' and id=5" )
    assert OrthomclGene.count >= 7
    assert OrthomclGene.find_by_orthomcl_name('dme|dmoe13aa')
    
    # real tests
    groups = OrthomclGroup.all_overlapping_groups(['dme'])
    assert_equal 2, groups.length, groups.inspect
    assert_equal [1,2].sort, groups.pick(:id).sort
    assert_kind_of OrthomclGroup, groups[0]
  end
  
  def test_empty_all_overlapping
    stupid = OrthomclGroup.all_overlapping_groups([])
    assert_equal OrthomclRun.official_run_v2.orthomcl_groups.count, stupid.length, stupid
  end
  
  def test_single_group_with_multiple_same_species_members
    groups = OrthomclGroup.all_overlapping_groups(['two'])
    assert_equal 1, groups.length, groups
    assert_equal 4, groups[0].id, groups
  end
  
  def test_single_members_by_codes
    assert OrthomclGroup.find(4).single_members_by_codes(['one'])
    assert_equal false, OrthomclGroup.find(4).single_members_by_codes(['two'])
    assert_equal false, OrthomclGroup.find(4).single_members_by_codes(['nup'])
  end
end
