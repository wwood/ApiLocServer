# 
# To change this template, choose Tools | Templates
# and open the template in the editor.
 

$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'simple_go'

class SimpleGoTest < Test::Unit::TestCase
  def test_obo_parser
    sg = SimpleGo.new('lib/testFiles/goTest.obo')
    e = sg.next_go
    assert e
    assert_equal 'GO:0000001', e.go_id
    assert_equal 'mitochondrion inheritance', e.name
    assert_equal 'biological_process', e.namespace
    assert_equal [], e.alternates
    
    e = sg.next_go
    assert e
    assert_equal 'GO:0000002', e.go_id
    assert_equal 'mitochondrial genome maintenance', e.name
    assert_equal 'biological_process', e.namespace
    assert_equal ['GO:0005279','GO:0005280'], e.alternates
    
    assert_nil sg.next_go
  end
  
  def test_map_parser
    sm = GoMapParser.new('lib/testFiles/goMapTest.map')
    
    e = sm.next_relation
    assert e
    assert_nil e.best_parent_id
    assert_nil e.all_parent_ids
        
    e = sm.next_relation
    assert e
    assert_equal ['GO:0008150'], e.best_parent_id
    assert_equal ['GO:0008150'], e.all_parent_ids
    
    e = sm.next_relation
    e = sm.next_relation
    
    e = sm.next_relation
    assert e
    assert_equal ['GO:0043226','GO:0005576'], e.best_parent_id
    assert_equal ['GO:0005575','GO:0043226','GO:0005576'], e.all_parent_ids
    
    assert_nil sm.next_relation
  end
  
  def test_count_real
    count = 0
    sg = SimpleGo.new("#{ENV['HOME']}/phd/data/GO/20080304/gene_ontology_edit.obo")

    while (g = sg.next_go)
      count = count+1
    end

    assert_equal 26077, count
  end

  def test_synonyms
    sg = SimpleGo.new("lib/testFiles/goTest.obo")
    e = sg.next_go
    assert_equal ['mitochondrial inheritance'], e.synonyms
    e = sg.next_go
    assert_nil e.synonyms
  end

  def test_multiple_synonyms
    sg = SimpleGo.new("lib/testFiles/goTestSynonyms.obo")
    e = sg.next_go
    assert_equal [
      "all-trans-heptaprenyl-diphosphate synthase activity",
      "all-trans-hexaprenyl-diphosphate:isopentenyl-diphosphate hexaprenyltranstransferase activity",
      "heptaprenyl diphosphate synthase activity",
      "heptaprenyl pyrophosphate synthase activity",
      "heptaprenyl pyrophosphate synthetase activity"],
      e.synonyms
  end
end
