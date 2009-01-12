# 
# To change this template, choose Tools | Templates
# and open the template in the editor.
 

$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'distance_matrix'

class DistanceMatrixTest < Test::Unit::TestCase
  def test_simple
    input = <<__END_OF_TESTDATA__
   A B
A  1 2
B  3 4
//
__END_OF_TESTDATA__
    d = DistanceMatrix.new
    d.load_matrix(input)
    assert_equal 1, d.get('A','A')
    assert_equal 2, d.get('B','A')
    assert_equal 4, d.get('B','B')
  end
  
  def test_negative_and_comments
    input = <<__END_OF_TESTDATA__
   A  B  C
A  1  2 -1
B  3  4 -2
C  5  6  8
//
__END_OF_TESTDATA__
    d = DistanceMatrix.new
    d.load_matrix(input)
    assert_equal 1, d.get('A','A')
    assert_equal 2, d.get('B','A')
    assert_equal 4, d.get('B','B')
    assert_equal(-1, d.get('C','A'))
  end
  
  def test_blosum62
    d = DistanceMatrix.blosum62
    assert_equal 4, d.get('A','A')
    assert_equal -1, d.get('A','R')
  end
end
