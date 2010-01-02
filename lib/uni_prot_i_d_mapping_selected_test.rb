# To change this template, choose Tools | Templates
# and open the template in the editor.

$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'uni_prot_i_d_mapping_selected'

class UniProtIDMappingSelectedTest < Test::Unit::TestCase
  def test_ensembl_protein
    uni = Bio::UniProtIDMappingSelected.new(File.join(File.dirname(__FILE__),'..','lib','testFiles','idmapping_selected.tab.example.gz'))
    e = uni.find_by_ensembl_protein_id('ENSP00000300161')
    assert_equal %w(ENSP00000300161 ENSP00000361930),
      e.ensembl_pro
  end
end
