require 'test_helper'

class ProteomicExperimentPeptideTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "regex" do
    assert_equal(/a(b)c/i, ProteomicExperimentPeptide.find(1).regex)
    assert_equal(/^(abc)g/i, ProteomicExperimentPeptide.find(2).regex)
    assert_equal(/a(bc)$/i, ProteomicExperimentPeptide.find(3).regex)
    assert_equal /^(MDFAYKQEAEEDCLISLDYILDKYDL)Y/i,
      ProteomicExperimentPeptide.new(:peptide => '-.MDFAYKQEAEEDCLISLDYILDKYDL.Y').regex
    assert_equal /^(MDFA)$/i,
      ProteomicExperimentPeptide.new(:peptide => '-.MDFA.-').regex
  end
end
