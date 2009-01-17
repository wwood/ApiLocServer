require File.dirname(__FILE__) + '/../test_helper'

class LocalisationTest < ActiveSupport::TestCase
  def setup
    @l = Localisation.new
  end
  
  def test_simple
    #simple
    stuff = @l.parse_name('apicoplast')
    assert_equal_expression_contexts [ExpressionContext.new(:localisation => Localisation.find_by_name('apicoplast'))],
      stuff, 'simple'
    
    #bad one
    assert_raise ParseException do
      @l.parse_name('not a localisation')
    end
  end
  
  #during
  def test_during
    stuff = @l.parse_name('apicoplast during schizont')
    assert_equal_expression_contexts [ExpressionContext.new(
        :localisation => Localisation.find_by_name('apicoplast'),
        :developmental_stage => DevelopmentalStage.find_by_name('schizont')
      )],
      stuff, 'during'
  end
  
  def test_not
    stuff = @l.parse_name('not apicoplast')
    assert_equal_expression_contexts [ExpressionContext.new(:localisation => Localisation.find_by_name('not apicoplast'))],
      stuff, "a simple not"
    
    #with a synonym
    stuff = @l.parse_name('not fv')
    assert_equal_expression_contexts [ExpressionContext.new(:localisation => Localisation.find_by_name('not food vacuole'))],
      stuff, "a simple not with synonym"
    
    assert_raise ParseException do
      @l.parse_name('not a localisation')
    end
  end
  
  def test_sort
    sorted = [ExpressionContext.new(
        :localisation => Localisation.find_by_name('apicoplast'),
        :developmental_stage => DevelopmentalStage.find_by_name('ring')
      ), ExpressionContext.new(
        :localisation => Localisation.find_by_name('apicoplast'),
        :developmental_stage => DevelopmentalStage.find_by_name('schizont')
      )].sort
    expected = [ExpressionContext.new(
        :localisation => Localisation.find_by_name('apicoplast'),
        :developmental_stage => DevelopmentalStage.find_by_name('schizont')
      ), ExpressionContext.new(
        :localisation => Localisation.find_by_name('apicoplast'),
        :developmental_stage => DevelopmentalStage.find_by_name('ring')
      )]

    assert_equal sorted.length, expected.length
    sorted.each_with_index do |sortee, index|
      assert_equal expected[index], sortee
    end
  end
  
  def test_comparison
    e1 = ExpressionContext.new(
      :localisation => Localisation.find_by_name('apicoplast'),
      :developmental_stage => DevelopmentalStage.find_by_name('schizont')
    )
    e2 = ExpressionContext.new(
      :localisation => Localisation.find_by_name('apicoplast'),
      :developmental_stage => DevelopmentalStage.find_by_name('schizont')
    )
    assert_equal 0, e1<=>e2
    
    e2.developmental_stage = DevelopmentalStage.find_by_name('ring')
    assert_equal DevelopmentalStage.find_by_name('schizont').id <=>
      DevelopmentalStage.find_by_name('ring').id, 
      e1 <=> e2
  end
    
  def test_single_synonym_to_multiple_dev_stages
    stuff = @l.parse_name('apicoplast during blood stages')
    assert_equal_expression_contexts [ExpressionContext.new(
        :localisation => Localisation.find_by_name('apicoplast'),
        :developmental_stage => DevelopmentalStage.find_by_name('schizont')
      ), ExpressionContext.new(
        :localisation => Localisation.find_by_name('apicoplast'),
        :developmental_stage => DevelopmentalStage.find_by_name('ring')
      ), ExpressionContext.new(
        :localisation => Localisation.find_by_name('apicoplast'),
        :developmental_stage => DevelopmentalStage.find_by_name('trophozoite')
      )].sort,
      stuff.sort, 'test_single_synonym_to_multiple_dev_stages'
  end
      
  #api, mito during 1 stage
  def test_two_locs_one_stage
    stuff = @l.parse_name('apicoplast and mitochondria during schizont')
    assert_equal_expression_contexts [
      ExpressionContext.new(:localisation => Localisation.find_by_name('apicoplast'), :developmental_stage => DevelopmentalStage.find_by_name('schizont')),
      ExpressionContext.new(:localisation => Localisation.find_by_name('mitochondria'), :developmental_stage => DevelopmentalStage.find_by_name('schizont'))
    ], stuff, '2 during 1'
  end
      
  # 2 during 2
  def test_two_and_two
    stuff = @l.parse_name('apicoplast and mitochondria during schizont and ring')
    contexts = [
      ExpressionContext.new(:localisation => Localisation.find_by_name('apicoplast'), :developmental_stage => DevelopmentalStage.find_by_name('schizont')),
      ExpressionContext.new(:localisation => Localisation.find_by_name('mitochondria'), :developmental_stage => DevelopmentalStage.find_by_name('schizont')),
      ExpressionContext.new(:localisation => Localisation.find_by_name('apicoplast'), :developmental_stage => DevelopmentalStage.find_by_name('ring')),
      ExpressionContext.new(:localisation => Localisation.find_by_name('mitochondria'), :developmental_stage => DevelopmentalStage.find_by_name('ring'))
    ].sort
    assert_equal_expression_contexts contexts, stuff.sort, '2 during 2'
  end
    
  def test_compare
    assert_equal 1, ExpressionContext.new(:coding_region_id => 2) <=> ExpressionContext.new(:coding_region_id => 1)
    assert_equal 0, ExpressionContext.new(:localisation_id => 2) <=> ExpressionContext.new(:localisation_id => 2)
  end
    
  def test_then
    stuff = @l.parse_name('mitochondria then apicoplast')
    contexts = [
      ExpressionContext.new(:localisation => Localisation.find_by_name('apicoplast'))
    ]
    assert_equal_expression_contexts contexts, stuff, 'test_then'
  end
    
  def test_and_then
    stuff = @l.parse_name('mitochondria then apicoplast during schizont')
    contexts = [
      ExpressionContext.new(:localisation => Localisation.find_by_name('apicoplast'), :developmental_stage => DevelopmentalStage.find_by_name('schizont'))
    ]
    assert_equal_expression_contexts contexts, stuff, 'test_then'
  end
    
    
  def test_known_named_scope
    assert_equal 1, Localisation.known.find_all_by_name('mitochondria').length #good
    assert Localisation.known.find_by_name('mitochondria') #good again
    assert_equal 'mitochondria', Localisation.known.find_by_name('mitochondria').name #good again
    assert_equal 0, Localisation.known.find_all_by_name('mitochondrias').length #stupid
    assert_equal 0, Localisation.known.find_all_by_name('fv').length #synonym
  end
    
    
    
  def assert_equal_expression_contexts(array_of_dev_stage_loc_objects_expected, actual, message)
    assert_equal array_of_dev_stage_loc_objects_expected.length, actual.length, "#{message}: length of arrays - #{array_of_dev_stage_loc_objects_expected.inspect} vs #{actual.inspect}"
    array_of_dev_stage_loc_objects_expected.each_with_index { |exp,index|
      act = actual[index]
      assert_kind_of ExpressionContext, act
      assert_equal exp.developmental_stage_id, act.developmental_stage_id, "#{message}: dev stage id #{index}: \n#{array_of_dev_stage_loc_objects_expected.inspect} vs \n#{actual.inspect}"
      assert_equal exp.localisation_id, act.localisation_id, "#{message}: localisation id: \n#{array_of_dev_stage_loc_objects_expected.inspect} vs \n#{actual.inspect}"
      assert_equal exp.coding_region_id, act.coding_region_id, "#{message}: coding region id: \n#{array_of_dev_stage_loc_objects_expected.inspect} vs \n#{actual.inspect}"
      assert_equal exp.publication_id, act.publication_id, "#{message}: publication_id: \n#{array_of_dev_stage_loc_objects_expected.inspect} vs \n#{actual.inspect}"
    }
  end
    
  def test_not_during
    assert_equal [ExpressionContext.new(
        :developmental_stage => DevelopmentalStage.find_by_name('not schizont')
      )],
      @l.parse_name('not during schizont')
  end
    
  def test_not_during_synonym
    assert_equal [ExpressionContext.new(
        :developmental_stage => DevelopmentalStage.find_by_name('my ring')
      )],
      @l.parse_name('not during my ring')
  end
end
