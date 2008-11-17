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
  
  def test_normlise
    me = [[1,3,-1],[1,2,2]]
    assert_equal [[0,1,0],[0,0,1]], me.normalise_columns
    
    assert_equal [[0,nil],[nil,nil]], [[10,nil],[nil,nil]].normalise_columns
  end
  
  def test_to_hash
    hash = {'a' => 0, 'b' => 1, 'c' => 2}
    assert_equal hash, ['a','b','c'].to_hash
    
    hash = {'a' => 0, 'b' => 1, 'c' => 3}
    assert_equal hash, ['a','b',nil,'c'].to_hash
    
    assert_raise Exception do
      [1,2,3,2,4].to_hash
    end
    
    hash = {}
    assert_equal hash, [].to_hash
  end
end
