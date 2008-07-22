# 
# To change this template, choose Tools | Templates
# and open the template in the editor.
 

$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'k_fold_cross_validator'
require 'rubygems'
gem 'activerecord'
require 'activerecord'
include Prediction



class PredictorResultTest < Test::Unit::TestCase
  def test_single_result_collection
    r = PredictorResult.new
    r.push TP
    r.push TN
    r.push FP
    r.push FN
    r.push NOT_PREDICTED
    assert_equal 0.5, r.sensitivity
    assert_equal 0.5, r.specificity
    assert_equal 0.8, r.coverage
    
    r.push TP
    assert_equal 2.0/3.0, r.sensitivity
  end
  
  
  def test_cross_validator
    cross = LocalisationKFoldCrossValidator.new
#    cross.k = 1
#    results = cross.cross_validate(DummyPredictor.new, DummyDataSet.new)
#    assert_equal 1, results.length
#    assert_equal 0.5, results[0].sensitivity
#    assert_equal 1, results[0].coverage
    
    cross.k = 2
    results = cross.cross_validate(DummyPredictor.new, DummyDataSet.new)
    assert_equal 2, results.length
    # ensure that random stuff is coming out of it
    dees = results.data_sets
    assert dees
    assert_equal 2, dees.length
    assert_not_equal dees[0].sort, dees[1].sort
    
    # over-sampling shouldn't be allowed (for now)
  end
  
end



class DummyDataSet<LocalisationDataSet
  # override
  def initialize
    100.downto(1){|n|store(n, 'number')}
  end
  
end


class DummyPredictor <AbstractPredictor
  def train(data_set)
    # just return me, don't do any training
    self
  end
    
  def validate(data_set)
    p = PredictorResult.new
    p.push TP
    p.push TN
    p.push FP
    p.push FN
  end
end
