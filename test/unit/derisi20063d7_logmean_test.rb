require File.dirname(__FILE__) + '/../test_helper'

class Derisi20063d7LogmeanTest < ActiveSupport::TestCase
  fixtures :derisi20063d7logmean, :coding_regions
  def test_truth
#    Derisi20063d7Logmean.find(:all, 
#      :include => :coding_region
#    ).each do |d|
#      puts d.plasmodbid
#      puts d.coding_region
#    end
    
    
    
    assert_equal 1, Derisi20063d7Logmean.find(:all, 
      :include => :coding_region,
      :conditions => 'coding_regions.id notnull'
    ).length
  end
end
