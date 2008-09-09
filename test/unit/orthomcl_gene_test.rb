require File.dirname(__FILE__) + '/../test_helper'

class OrthomclGeneTest < ActiveSupport::TestCase
  fixtures :orthomcl_genes, :coding_regions, :orthomcl_groups, :orthomcl_runs
  
  def test_accepted_database_id
    assert_equal 'PF01', OrthomclGene.find(1).accepted_database_id
    
    # upcase for arabidopsis genes
    assert_equal 'AD01', OrthomclGene.find(2).accepted_database_id
  end
  
  def test_compute_coding_region
    
    assert OrthomclGene.find(1).orthomcl_group
    
    code = OrthomclGene.find(12).compute_coding_region
    assert code
    assert_equal 5, code.id
  end
  
  def test_compute_coding_region!
    g = OrthomclGene.create!(
      :orthomcl_name => 'pfa|PF1.1',
      :orthomcl_group_id => 2
    )
    assert g
    assert_difference('CodingRegion.count', 0) {
      g.compute_coding_region!
    }
    g = OrthomclGene.create!(
      :orthomcl_name => 'pfa|PF1.1no_way',
      :orthomcl_group_id => 2
    )
    assert_difference('CodingRegion.count', 1) {
      g.compute_coding_region!
    }
  end
  
  def test_code_named_scope
    assert OrthomclGene.code('ath').all.pick(:orthomcl_name).include?('ath|ad01')
    assert_equal false, OrthomclGene.code('ath').all.pick(:orthomcl_name).include?('pfa|PF01')
  end
  
  def test_codes_named_scope
    assert_equal 3, OrthomclGene.codes(['two']).count
    assert_equal 4, OrthomclGene.codes(['two','one']).count
  end
end
