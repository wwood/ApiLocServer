require 'test_helper'

class MousePhenotypeInformationTest < ActiveSupport::TestCase
  def test_lethal?
    assert_equal true, MousePhenotypeInformation.find(1).lethal?
    assert_equal false, MousePhenotypeInformation.find(2).lethal?
    assert_equal false, MousePhenotypeInformation.find(3).lethal?
    assert_equal false, MousePhenotypeInformation.find(4).lethal?
  end
end