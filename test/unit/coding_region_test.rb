require File.dirname(__FILE__) + '/../test_helper'

class CodingRegionTest < ActiveSupport::TestCase
  fixtures :genes, 
    :scaffolds, 
    :coding_regions, 
    :cds, 
    :coding_region_alternate_string_ids,
    :species
  
  def test_get_first_base_scaffold_wise
    #nadda
    assert_equal nil, CodingRegion.find(1).calculate_upstream_region
    
    # positive strand
    assert_equal 40, CodingRegion.find(2).calculate_upstream_region
    
    # negative strand
    assert_equal 40, CodingRegion.find(3).calculate_upstream_region
    
    # different scaffold
    assert_nil CodingRegion.find(4).calculate_upstream_region
    
  end
  
  def test_get_by_normal_or_alternate
    #normal
    c = CodingRegion.find_by_name_or_alternate 'PF1.1'
    assert c
    assert_kind_of CodingRegion, c
    assert_equal 6, c.id
    
    #alternate
    c = CodingRegion.find_by_name_or_alternate 'blah'
    assert c
    assert_kind_of CodingRegion, c
    assert_equal 6, c.id
    
    #nil
    c = CodingRegion.find_by_name_or_alternate 'blahno'
    assert_nil c
  end
  
  def test_get_by_normal_or_alternate_with_species
    # test easy - 1 gene with 1 name
    code = CodingRegion.find_by_name_or_alternate_and_organism('PF1', 'falciparum')
    assert code
    assert_equal 5, code.id
    
    # test no results
    code = CodingRegion.find_by_name_or_alternate_and_organism('PF1', 'sponge')
    assert_nil code
    
    # test hard to coding regions with same name but different species
    code = CodingRegion.find_by_name_or_alternate_and_organism('PF01', 'falciparum')
    assert code
    assert_equal 7, code.id
    code = CodingRegion.find_by_name_or_alternate_and_organism('PF01', 'sponge')
    assert code
    assert_equal 8, code.id
    
    #wierd chars in name
    assert CodingRegion.find_by_name_or_alternate_and_organism("PF01'", 'falciparum')
    
    
    # could test mroe here with alternates, but meh
    
  end
  
  def test_single_gene
    # test good
    o = CodingRegion.find(2).single_orthomcl
    assert_kind_of OrthomclGene, o
    assert_equal 2, o.id
    
    # test fail with no orthomcl gene
    assert_raise CodingRegion::UnexpectedOrthomclGeneCount do
      CodingRegion.find(7).single_orthomcl
    end
    
    # test fail with multiple orthomcl genes
    assert_raise CodingRegion::UnexpectedOrthomclGeneCount do
      CodingRegion.find(1).single_orthomcl
    end
    
    # test fail when single one is non-official
    assert_raise CodingRegion::UnexpectedOrthomclGeneCount do
      CodingRegion.find(3).single_orthomcl
    end
  end
  
  def test_wormnet_core_total_linkage_scores
    # test normal, that includes non wormnet and wormnet non core decoys
    assert_equal 3.2, CodingRegion.find(4).wormnet_core_total_linkage_scores
    
    # test nothing
    assert_equal 0.0, CodingRegion.find(3).wormnet_core_total_linkage_scores
  end
  
  def test_is_enzyme?
    assert CodingRegion.find(2).is_enzyme?
    assert_equal false, CodingRegion.find(1).is_enzyme?
  end
  
  def test_is_gpcr?
    # plain gpcr
    assert CodingRegion.find(3).is_gpcr?
    
    # gpcr offspring
    assert CodingRegion.find(4).is_gpcr?
    
    # false
    assert_equal false, CodingRegion.find(2).is_gpcr?
  end
  
  def test_enzyme_then_gpcr_bug
    assert CodingRegion.find(3).is_gpcr?
    assert_equal false, CodingRegion.find(3).is_enzyme?
  end
end
