require 'test_helper'

class ConsensusSequenceTest < ActiveSupport::TestCase
  
  def test_new
    assert ConsensusSequence.new
  end
  
  def test_florian_fill_golgi_n
    assert_difference('GolgiNTerminalSignal.count', 9) do
      GolgiNTerminalSignal.new.florian_fill
    end
    
    f = GolgiNTerminalSignal.find_by_signal('^..R')
    assert f
    assert_equal(/^..R/, f.regex)
    assert 'ABRD'.match(f.regex)
    assert !'R'.match(f.regex)
  end
  
  def test_florian_fill_golgi_c
    GolgiCTerminalSignal.new.florian_fill
    efs = GolgiCTerminalSignal.find_all_by_signal('KK..$')
    assert_equal 1, efs.length
    assert 'KKXX'.match(efs[0].regex)
  end
end
