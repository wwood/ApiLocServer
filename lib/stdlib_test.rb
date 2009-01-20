# 
# To change this template, choose Tools | Templates
# and open the template in the editor.
 

$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'stdlib'

class StdlibTest < Test::Unit::TestCase
  def test_to_i?
    assert '1'.to_i?
    assert_equal false, 'e'.to_i?
    assert_equal false, '1e'.to_i?
    assert_equal false, ''.to_i?
  end
  def test_to_f?
    assert '1.6'.to_f?
    assert '1'.to_f?
    
    # irb(main):002:0> '1.12E-125'.to_f.to_s
    # => "1.12e-125"
    assert '1.12E-125'.to_f?
    
    assert_equal false, 'e'.to_f?
    assert_equal false, '1e'.to_f?
    assert_equal false, ''.to_f?
    
    # Known bug
    assert '1.120E-125'.to_f?
  end
end
