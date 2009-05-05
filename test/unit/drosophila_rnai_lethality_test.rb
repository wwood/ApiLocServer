require 'test_helper'

class DrosophilaRnaiLethalityTest < ActiveSupport::TestCase
  def test_lethal?
    assert_equal true, DrosophilaRnaiLethality.find(1).lethal?
    assert_equal true, DrosophilaRnaiLethality.find(2).lethal?
    assert_equal true, DrosophilaRnaiLethality.find(3).lethal?
    assert_equal true, DrosophilaRnaiLethality.find(4).lethal?
    assert_equal false, DrosophilaRnaiLethality.find(5).lethal?
  end


end
