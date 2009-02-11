require File.dirname(__FILE__) + '/../test_helper'

class SignalPCacheTest < ActiveSupport::TestCase
  def setup
    @seq_with_signal = "MKKIITLKNLFLIILVYIFSEKKDLRCNVIKGNNIK"
    @seq_without_signal = "MRRRRRRRRRRRRRRRRRRRRRRRRR" #ie lotsa charge
  end
  
  def test_cache
    res = SignalSequence::SignalPWrapper.new.calculate(@seq_with_signal)
    assert_differences([CodingRegion, SignalPCache], nil, [0,1]) do
      sp = SignalPCache.create_from_result(2, res)
      assert_equal 0.336, sp.nn_Cmax #test simple
      assert_equal true, sp.nn_Smax_prediction #test boolean, which maps slightly differently
      assert sp.signal? #test defer to SignalPResult object
    end
    
    res = SignalSequence::SignalPWrapper.new.calculate(@seq_without_signal)
    assert_differences([CodingRegion, SignalPCache], nil, [0,1]) do
      sp = SignalPCache.create_from_result(3, res)
      assert_equal 0.32, sp.nn_Smax #test simple
      assert_equal false, sp.nn_Smax_prediction #test boolean, which maps slightly differently
      assert_equal false, sp.signal? #test defer to SignalPResult object
    end
  end
end
