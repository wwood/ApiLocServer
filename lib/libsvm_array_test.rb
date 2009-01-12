# 
# To change this template, choose Tools | Templates
# and open the template in the editor.
 

$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'libsvm_array'

class LibsvmArrayTest < Test::Unit::TestCase
  def test_foo
    assert_equal '1 1:2.0', [2].libsvm_format(1)
    assert_equal '-1 1:3.5 2:4.08', [3.5, 4.08].libsvm_format('-1')
  end
end
