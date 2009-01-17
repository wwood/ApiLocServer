require 'test_helper'

class DevelopmentalStageTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  def test_find_all_by_name_or_alternate
    # find none
    assert_equal [], DevelopmentalStage.find_all_by_name_or_alternate('not a stage')
    
    # find normal non-synonym
    assert_equal [DevelopmentalStage.find_by_name('ring')],
      DevelopmentalStage.find_all_by_name_or_alternate('ring')
    
    # find single synonym
    assert_equal [DevelopmentalStage.find_by_name('ring')],
      DevelopmentalStage.find_all_by_name_or_alternate('my ring')
    
    # find one where there is one synonym meaning multiple
    # stages, like 'blood stages'
    assert_equal [DevelopmentalStage.find_by_name('ring'), 
      DevelopmentalStage.find_by_name('schizont'), 
      DevelopmentalStage.find_by_name('trophozoite')].sort,
      DevelopmentalStage.find_all_by_name_or_alternate('blood stages').sort
  end
  
  def test_add_not
    assert_equal "not ringer", DevelopmentalStage.add_negation('ringer')
  end
end
