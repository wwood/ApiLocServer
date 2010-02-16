require "test/unit"

$:.unshift File.join(File.dirname(__FILE__),'..','lib')
require 'ontology_comparison'

class OntologyComparisonTest < Test::Unit::TestCase
  
  def test_agreement_of_pair
    c = OntologyComparison.new
    c.agreement_of_pair(%w(loc1),%w(loc1))
    assert_kind_of OntologyComparison, c
    assert_equal OntologyComparison::COMPLETE_AGREEMENT, c.agreement
  end
  
  def test_disagreement_of_pair
    c = OntologyComparison.new
    c.agreement_of_pair(%w(loc1),%w(loc2))
    assert_kind_of OntologyComparison, c
    assert_equal OntologyComparison::DISAGREEMENT, c.agreement
  end
  
  def test_incomplete_greement_of_pair
    c = OntologyComparison.new
    c.agreement_of_pair(%w(loc1),%w(loc2 loc1))
    assert_kind_of OntologyComparison, c
    assert_equal OntologyComparison::INCOMPLETE_AGREEMENT, c.agreement
  end
  
  def test_compare
    c1 = OntologyComparison.new
    c2 = OntologyComparison.new
    c1.agreement = OntologyComparison::COMPLETE_AGREEMENT
    c2.agreement = OntologyComparison::DISAGREEMENT
    assert_equal 1, c1<=>c2
    
    c1.agreement = OntologyComparison::INCOMPLETE_AGREEMENT
    c2.agreement = OntologyComparison::INCOMPLETE_AGREEMENT
    assert_equal 0, c1<=>c2
    
    c1.agreement = OntologyComparison::INCOMPLETE_AGREEMENT
    c2.agreement = OntologyComparison::COMPLETE_AGREEMENT
    assert_equal -1, c1<=>c2
  end
  
  def test_max
    c1 = OntologyComparison.new
    c2 = OntologyComparison.new
    c3 = OntologyComparison.new
    c1.agreement = OntologyComparison::INCOMPLETE_AGREEMENT
    c2.agreement = OntologyComparison::DISAGREEMENT
    c3.agreement = OntologyComparison::COMPLETE_AGREEMENT
    assert_equal c3, [c1, c2, c3].max 
  end
  
  def test_group_agreement
    assert_equal OntologyComparison::COMPLETE_AGREEMENT, OntologyComparison.new.agreement_of_group([%w(1),%w(1)])
    assert_equal OntologyComparison::COMPLETE_AGREEMENT, OntologyComparison.new.agreement_of_group([%w(1),%w(1),%w(1)])
    assert_equal OntologyComparison::DISAGREEMENT, OntologyComparison.new.agreement_of_group([%w(1),%w(1),%w(2)])
    assert_equal OntologyComparison::UNKNOWN_AGREEMENT, OntologyComparison.new.agreement_of_group([%w(),%w()])
  end
end