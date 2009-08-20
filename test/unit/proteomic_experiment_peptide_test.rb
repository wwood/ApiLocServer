require 'test_helper'

class ProteomicExperimentPeptideTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "regex" do
    assert_equal(/abc/i, ProteomicExperimentPeptide.find(1).regex)
    assert_equal(/^gabc/i, ProteomicExperimentPeptide.find(2).regex)
    assert_equal(/abc$/i, ProteomicExperimentPeptide.find(3).regex)
  end
end
