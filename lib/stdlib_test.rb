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
end
