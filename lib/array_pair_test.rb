# 
# To change this template, choose Tools | Templates
# and open the template in the editor.
 

$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'array_pair'

class ArrayPairTest < Test::Unit::TestCase
  def test_within
    me = [1,2,3]
    assert_equal [[1,2],[1,3],[2,3]], me.pairs
  end
  
  def test_between
    me = [1,2]
    you = [4,5,6]
    assert_equal [[1,4],[1,5],[1,6],[2,4],[2,5],[2,6]], me.pairs(you)
  end
end
