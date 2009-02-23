require File.dirname(__FILE__) + '/../test_helper'

class OrthomclGeneTest < ActiveSupport::TestCase
  fixtures :orthomcl_genes, :coding_regions, :orthomcl_groups, :orthomcl_runs
  
  def test_accepted_database_id
    assert_equal 'PF01', OrthomclGene.find(1).accepted_database_id
    
    # upcase for arabidopsis genes
    assert_equal 'AD01', OrthomclGene.find(2).accepted_database_id
  end
  
  def test_compute_coding_regions
    
    assert OrthomclGene.find(1).orthomcl_group
    
    codes = OrthomclGene.find(12).compute_coding_regions
    assert codes
    assert_equal 1, codes.length
    assert_equal 5, codes[0].id
  end
  
  def test_code_named_scope
    assert OrthomclGene.code('ath').all.pick(:orthomcl_name).include?('ath|ad01')
    assert_equal false, OrthomclGene.code('ath').all.pick(:orthomcl_name).include?('pfa|PF01')
  end
  
  def test_codes_named_scope
    assert_equal 3, OrthomclGene.codes(['two']).count
    assert_equal 4, OrthomclGene.codes(['two','one']).count
  end
  
  def test_code?
    assert_equal true, OrthomclGene.find(1).code?('pfa')
    assert_equal false, OrthomclGene.find(2).code?('tgo')
    assert_equal nil, OrthomclGene.find(13).code?('tgo')
  end
end
