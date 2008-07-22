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
end
