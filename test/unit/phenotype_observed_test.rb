require 'test_helper'

class PhenotypeObservedTest < ActiveSupport::TestCase
  
  def test_lethal?
    obs = PhenotypeObserved.new
    
    obs.phenotype = 'nada'
    assert !obs.lethal?
    
    obs.phenotype = 'yalethal'
    assert obs.lethal?
    
    obs.phenotype = 'almostLetha.'
    assert !obs.lethal?
    
    obs.phenotype = 'LETHALISTY'
    assert obs.lethal?
  end
end
