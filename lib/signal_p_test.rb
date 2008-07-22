# 
# To change this template, choose Tools | Templates
# and open the template in the editor.
 

$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'signalp'

class SignalPTest < Test::Unit::TestCase
  def test_parse_simple
    line = '547.m00089            0.263  21 Y  0.153  21 N  0.399   2 N  0.241 N  0.197 N	547.m00089  Q  0.003  19 N  0.004 N'
    result = SignalPResult.create_from_line(line)
    
    assert_equal 0.263, result.nn_Cmax
    assert_equal true, result.nn_Cmax_prediction
    assert_equal false, result.nn_Ymax_prediction
    assert_equal 0.003, result.hmm_Cmax
    assert_equal 19, result.hmm_Cmax_position
  end
  
  def test_calculate_sequence
    seq = "MRFISILTYIQKSSWVDCVDLKQLSNHGGQRKATITVDFKLIKESYTSVVHFNPHDRIKAVAANNDLFEVLDTVWEFKDIGDATEVDFNIKFKFHSGMYQTITTYMGRTLSGSMVDHFVKECYRRHNLKKIPFQKEHVGI"
    result = SignalPWrapper.new.calculate(seq)
    assert_equal 0.346, result.nn_Cmax
    
    seq = 'MSTLISTLFVCVCVVYVPLLFCAVDGATLSAIPLSPRFTESRGIGVDERVEPYPTIRVYAYTPRGTFNPSSPSYSKRLTRVLESEAYRSGSLGIKGLHSRLLQLQVGYYCVMYHVVLDASEKHG'
    result = SignalPWrapper.new.calculate(seq)
    assert_equal true, result.signal?
  end
  
  def test_overall
    line = '547.m00089            0.263  21 Y  0.153  21 N  0.399   2 N  0.241 N  0.197 N	547.m00089  Q  0.003  19 N  0.004 N'
    result = SignalPResult.create_from_line(line)
    assert_equal false, result.signal?
    
    line = '547.m00089            0.263  21 Y  0.153  21 N  0.399   2 N  0.241 N  0.197 Y	547.m00089  Q  0.003  19 N  0.004 N'
    result = SignalPResult.create_from_line(line)
    assert_equal true, result.signal?
    
    line = '547.m00089            0.263  21 Y  0.153  21 N  0.399   2 N  0.241 N  0.197 N	547.m00089  Q  0.003  19 N  0.004 Y'
    result = SignalPResult.create_from_line(line)
    assert_equal true, result.signal?
    
    
    line = '547.m00089            0.263  21 Y  0.153  21 N  0.399   2 N  0.241 N  0.197 Y	547.m00089  Q  0.003  19 N  0.004 Y'
    result = SignalPResult.create_from_line(line)
    assert_equal true, result.signal?
    
    line =  'BBOV_I000830          0.795  25 Y  0.765  25 Y  0.967  12 Y  0.838 Y  0.802 Y	BBOV_I000830  S  0.821  25 Y  0.961 Y '
    result = SignalPResult.create_from_line(line)
    assert_equal true, result.signal?
  end
  
  
  def test_cleaveage
    # actually has a site
    line =  'BBOV_I000830          0.795  25 Y  0.765  2 Y  0.967  12 Y  0.838 Y  0.802 Y	BBOV_I000830  S  0.821  25 Y  0.961 Y '
    result = SignalPResult.create_from_line(line)
    assert_equal 'GC', result.cleave('AGC')
    
    # doesn't have a site
    line =  'BBOV_I000830          0.795  25 N  0.765  2 N  0.967  12 N  0.838 N  0.802 N	BBOV_I000830  S  0.821  25 N  0.961 N '
    result = SignalPResult.create_from_line(line)
    assert_equal 'AGC', result.cleave('AGC')
  end
  
end
