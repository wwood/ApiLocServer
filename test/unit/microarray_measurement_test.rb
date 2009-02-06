require File.dirname(__FILE__) + '/../test_helper'

class MicroarrayMeasurementTest < ActiveSupport::TestCase
  fixtures :microarray_measurements
  
  def test_percentile
    assert_equal 0.5, MicroarrayMeasurement.find(2).percentile
    assert_equal 1.0, MicroarrayMeasurement.find(1).percentile
    assert_equal 1.0, MicroarrayMeasurement.find(3).percentile
    assert_equal 0.0, MicroarrayMeasurement.find(4).percentile
  end
end
