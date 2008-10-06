$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'rubygems'
require 'test/unit'
require 'go'

class GoTest < Test::Unit::TestCase
  def setup
    @go = Bio::Go.new
  end
  
  def test_cellular_component_offspring
    # test no offspring
    assert_equal [], @go.cellular_component_offspring('GO:0042717')
    
    # test multiple offspring
    assert_equal ["GO:0030075","GO:0030077","GO:0030078","GO:0030079","GO:0030080",
      "GO:0030081","GO:0030082","GO:0030089","GO:0030094","GO:0030096",
      "GO:0031633","GO:0031676","GO:0031979","GO:0042717","GO:0048493",
      "GO:0048494"
    ],
      @go.cellular_component_offspring('GO:0042716')
    
    # test not in CC
    assert_raise RException do
      @go.cellular_component_offspring('GO:0042716not')
    end
  end
  
  # operations below are expensive because they require
  # multiple downloads from internet, so are commented
  # out by default
  #  def test_cc_pdb_to_go_some
  #    assert_equal ['GO:0005743'],
  #      @go.cc_pdb_to_go('2a06')
  #  end
  
  def test_go_term
    # test MF
   assert_equal "G-protein coupled receptor activity", @go.term('GO:0004930')
   
    # test CC
    assert_equal 'endoplasmic reticulum', @go.term('GO:0005783')
  end
end
