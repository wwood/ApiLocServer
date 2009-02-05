require 'test_helper'

class MousePhenoDescTest < ActiveSupport::TestCase
  def test_lethal?
    assert_equal true, MousePhenoDesc.find(1).lethal?
    assert_equal false, MousePhenoDesc.find(2).lethal?
    assert_equal false, MousePhenoDesc.find(3).lethal?
    assert_equal false, MousePhenoDesc.find(4).lethal?
  end
end