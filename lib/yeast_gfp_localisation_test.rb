# 
# To change this template, choose Tools | Templates
# and open the template in the editor.
 

$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'yeast_gfp_localisation'

class YeastGfpLocalisationTest < Test::Unit::TestCase
  def test_big
    locs = YeastGfpLocalisation.new "#{ENV['HOME']}/phd/data/yeast/yeastgfp/allOrfData.txt"
    
    assert_equal ['ambiguous','mitochondrion','vacuole','spindle pole',
      'cell periphery','punctate composite','vacuolar membrane','ER',
      'nuclear periphery','endosome','bud neck','microtubule','Golgi',
      'late Golgi','peroxisome','actin','nucleolus','cytoplasm','ER to Golgi',
      'early Golgi','lipid particle','nucleus','bud'],
      locs.localisations
    
    l = locs.next_loc
    assert l
    assert_equal 'YAL001C', l.orf_name
    assert_equal ['cytoplasm','nucleus'], l.localisations
    
    count = 1
    while l = locs.next_loc
      last = l
      count = count+1
      
      # test one with no localisations - not sure why this even exists though
      if l.orf_name === 'YFL030W'
        assert_nil l.localisations
      end
      
      if l.orf_name === 'YFL007W'
        print "FOUND: "
        p l
      end
    end
    assert_equal 'YPR191W', last.orf_name
    assert_equal ['mitochondrion'], last.localisations
    assert_equal 4160, count
  end
end
