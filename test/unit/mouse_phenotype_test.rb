require 'test_helper'

class MousePhenotypeTest < ActiveSupport::TestCase
  def test_lethal?
    assert_equal true, MousePhenotype.find(1).lethal?
    assert_equal false, MousePhenotype.find(2).lethal?
    assert_equal false, MousePhenotype.find(3).lethal?
    assert_equal false, MousePhenotype.find(4).lethal?
  end
  
  def test_by_mutation
    assert_equal true, MousePhenotype.find(1).by_mutation?
    assert_equal false, MousePhenotype.find(2).by_mutation?
    assert_equal false, MousePhenotype.find(3).by_mutation?
    assert_equal true, MousePhenotype.find(4).by_mutation?
  end
end