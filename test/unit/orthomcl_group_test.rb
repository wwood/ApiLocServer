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
    assert_equal OrthomclRun.find_by_name(OrthomclRun::ORTHOMCL_OFFICIAL_NEWEST_NAME).orthomcl_groups.count(:select => 'distinct(orthomcl_group_id)'), stupid.length, stupid.inspect
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
    
    assert OrthomclGroup.find(1).single_members_by_codes(['pfa','ath'])
    assert_equal false,  OrthomclGroup.find(1).single_members_by_codes(['pfa','ath','nup'])
  end
  
  def test_with_species
    # test one species
    assert_equal 1, OrthomclGroup.with_species('pfa').first(:order => 'id').id
    # test not first one species
    assert_equal 4, OrthomclGroup.with_species('two').first(:order => 'id').id
    # setup for testing multiple species - make sure that both species in previous groups,
    # but this is the first group that has both species in it (when ordered by orthomcl_groups.id)
    assert_equal 3, OrthomclGroup.with_species('pber').first(:order => 'id').id
    # test multiple species
    assert_equal 4, OrthomclGroup.with_species('pfa').with_species('pber').first(:order => 'id').id
  end
end
