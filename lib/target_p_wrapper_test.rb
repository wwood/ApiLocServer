# 
# To change this template, choose Tools | Templates
# and open the template in the editor.
 

$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'target_p_wrapper'

class TargetPWrapperTest < Test::Unit::TestCase
  def test_foo
    assert t
  end
end
