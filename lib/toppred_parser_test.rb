# 
# To change this template, choose Tools | Templates
# and open the template in the editor.
 

$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'toppred_parser'

class ToppredParserTest < Test::Unit::TestCase
  def test_all
    parser = ToppredParser.new('lib/testFiles/toppred.out')
    
    p = parser.next_prediction
    assert p
    assert_kind_of TransmembraneProtein, p
    assert_equal 'Plasmodium_falciparum_3D7_MAL8_MAL8P1_161_Annotation_Plasmodium_falciparum_Sanger_Stanford_TIGR__protein', p.name
    tmds =p.transmembrane_domains 
    assert tmds
    assert_equal 1, tmds.length
    assert_equal 162, tmds[0].start
    assert_equal 182, tmds[0].stop
    assert_equal 21, tmds[0].length
    
    p = parser.next_prediction
    assert p
    assert_kind_of TransmembraneProtein, p
    assert_equal 'Plasmodium_falciparum_3D7_MAL8_PF08_0136_Annotation_Plasmodium_falciparum_Sanger_Stanford_TIGR__protein', p.name
    tmds =p.transmembrane_domains 
    assert tmds
    assert_equal 0, tmds.length
        
    p = parser.next_prediction
    assert p
    assert_kind_of TransmembraneProtein, p
    assert_equal 'Plasmodium_falciparum_3D7_MAL8_MAL8P1_156_Annotation_Plasmodium_falciparum_Sanger_Stanford_TIGR__protein', p.name
    tmds =p.transmembrane_domains 
    assert tmds
    assert_equal 2, tmds.length
    assert_equal 303, tmds[0].start
    assert_equal 323, tmds[0].stop
    assert_equal 976, tmds[1].start
    assert_equal 996, tmds[1].stop
  end
end
