require File.dirname(__FILE__) + '/../test_helper'

require File.dirname(__FILE__)+'/../../lib/test_helpers' #not the standard rail one


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
    err = capture_stderr do
      @l.parse_name('not a localisation')
    end
    assert_equal "Localisation not understood: 'not a localisation' from 'not a localisation'\n", err
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

    err = capture_stderr do
      @l.parse_name('not a localisation')
    end
    assert_equal "Localisation not understood: 'not a localisation' from 'not a localisation'\n", err
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

  # commented out then types because they are deprecated
  #  def test_then
  #    stuff = @l.parse_name('mitochondria then apicoplast')
  #    contexts = [
  #      ExpressionContext.new(:localisation => Localisation.find_by_name('apicoplast'))
  #    ]
  #    assert_equal_expression_contexts contexts, stuff, 'test_then'
  #  end
  #
  #  def test_and_then
  #    stuff = @l.parse_name('mitochondria then apicoplast during schizont')
  #    contexts = [
  #      ExpressionContext.new(:localisation => Localisation.find_by_name('apicoplast'), :developmental_stage => DevelopmentalStage.find_by_name('schizont'))
  #    ]
  #    assert_equal_expression_contexts contexts, stuff, 'test_then'
  #  end


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
        :developmental_stage => DevelopmentalStage.find_by_name('not ring')
      )],
      @l.parse_name('not during my ring')
  end

  def test_not_during_in_positive_during_with_alternate
    expected = [
      ExpressionContext.new(:developmental_stage => DevelopmentalStage.find_by_name('schizont')),
      ExpressionContext.new(:developmental_stage => DevelopmentalStage.find_by_name('not ring')),
      ExpressionContext.new(:developmental_stage => DevelopmentalStage.find_by_name('not trophozoite')),
    ].sort
    assert_equal expected,
      @l.parse_name('during schizont and not ring and not troph').sort
  end

  def test_not_during_in_positive_during
    expected = [
      ExpressionContext.new(:developmental_stage => DevelopmentalStage.find_by_name('schizont')),
      ExpressionContext.new(:developmental_stage => DevelopmentalStage.find_by_name('not ring')),
      ExpressionContext.new(:developmental_stage => DevelopmentalStage.find_by_name('not trophozoite')),
    ].sort
    assert_equal expected,
      @l.parse_name('during schizont and not ring and not trophozoite').sort
  end

  def test_remove_strength_modifiers
    assert_equal 'yey', Localisation.new.remove_strength_modifiers('yey')
    assert_equal false, Localisation.new.remove_strength_modifiers('weak yey')
  end

  def test_weak_during
    assert_equal [], Localisation.new.parse_name('weak during schizont')
    assert_equal [
      ExpressionContext.new(
        :developmental_stage => DevelopmentalStage.find_by_name('ring')
      )],
      Localisation.new.parse_name('during ring, weak during schizont')

    # test another 'weak' modifier
    assert_equal [], Localisation.new.parse_name('sometimes during schizont')
    assert_equal [
      ExpressionContext.new(
        :developmental_stage => DevelopmentalStage.find_by_name('ring')
      )],
      Localisation.new.parse_name('during ring, sometimes during schizont')
  end

  def test_weak_localisation
    assert_equal [], Localisation.new.parse_name('little')
    assert_equal [], Localisation.new.parse_name('little apicoplast')
    assert_equal [ExpressionContext.new(
        :localisation => Localisation.find_by_name('apicoplast')
      )], Localisation.new.parse_name('strong apicoplast')
  end

  def test_modifier_during
    assert_equal [
      ExpressionContext.new(
        :developmental_stage => DevelopmentalStage.find_by_name('schizont')
      )],
      Localisation.new.parse_name('strong during schizont')
  end
end
