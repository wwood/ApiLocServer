require File.dirname(__FILE__) + '/../test_helper'

class ScriptTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  def test_phase_to_timepoint
    script = Script.new
    
    assert_equal 12, script.phase_to_timepoint(0)
    assert_equal 36, script.phase_to_timepoint(-Math::PI)
    assert_equal 48.0/3.0, script.phase_to_timepoint(-Math::PI/6)
    assert_equal 8, script.phase_to_timepoint(Math::PI/6)
  end
end
