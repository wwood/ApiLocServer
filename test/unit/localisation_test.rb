require File.dirname(__FILE__) + '/../test_helper'

class LocalisationTest < ActiveSupport::TestCase
  def setup
    @l = Localisation.new
  end
  
  def test_simple
    #simple
    stuff = @l.parse_name('apicoplast')
    assert_equal_dsla [DevelopmentalStageLocalisation.new(:localisation => Localisation.find_by_name('apicoplast'))],
      stuff, 'simple'
  end
  
  #during
  def test_during
    stuff = @l.parse_name('apicoplast during schizont')
    assert_equal_dsla [DevelopmentalStageLocalisation.new(
        :localisation => Localisation.find_by_name('apicoplast'),
        :developmental_stage => DevelopmentalStage.find_by_name('schizont')
      )],
      stuff, 'during'
  end
    
  #api, mito during 1 stage
  def test_two_locs_one_stage
    stuff = @l.parse_name('apicoplast and mitochondria during schizont')
    assert_equal_dsla [
      DevelopmentalStageLocalisation.new(:localisation => Localisation.find_by_name('apicoplast'), :developmental_stage => DevelopmentalStage.find_by_name('schizont')),
      DevelopmentalStageLocalisation.new(:localisation => Localisation.find_by_name('mitochondria'), :developmental_stage => DevelopmentalStage.find_by_name('schizont'))
    ], stuff, '2 during 1'
  end
    
  # 2 during 2
  def test_two_and_two
    stuff = @l.parse_name('apicoplast and mitochondria during schizont and ring')
    assert_equal_dsla [
      DevelopmentalStageLocalisation.new(:localisation => Localisation.find_by_name('apicoplast'), :developmental_stage => DevelopmentalStage.find_by_name('schizont')),
      DevelopmentalStageLocalisation.new(:localisation => Localisation.find_by_name('mitochondria'), :developmental_stage => DevelopmentalStage.find_by_name('schizont')),
      DevelopmentalStageLocalisation.new(:localisation => Localisation.find_by_name('apicoplast'), :developmental_stage => DevelopmentalStage.find_by_name('ring')),
      DevelopmentalStageLocalisation.new(:localisation => Localisation.find_by_name('mitochondria'), :developmental_stage => DevelopmentalStage.find_by_name('ring'))
    ].sort, stuff.sort, '2 during 2'
    
    #1 during 1, 2
  end
  
  
  def assert_equal_dsla(array_of_dev_stage_loc_objects_expected, actual, message)
    assert_equal array_of_dev_stage_loc_objects_expected.length, actual.length, "#{message}: length of arrays - #{array_of_dev_stage_loc_objects_expected.inspect} vs #{actual.inspect}"
    array_of_dev_stage_loc_objects_expected.each_with_index { |exp,index|
      act = actual[index]
      assert_kind_of DevelopmentalStageLocalisation, act
      assert_equal exp.developmental_stage_id, act.developmental_stage_id, "#{message}: dev stage id #{index}: \n#{array_of_dev_stage_loc_objects_expected.inspect} vs \n#{actual.inspect}"
      assert_equal exp.localisation_id, act.localisation_id, "#{message}: dev stage id"
    }
  end
    
end
