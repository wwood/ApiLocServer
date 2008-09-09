# 
# To change this template, choose Tools | Templates
# and open the template in the editor.
 

$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'export_pred'

class ExportPredTest < Test::Unit::TestCase
  def setup
    @exportpred = Bio::ExportPred::Wrapper.new
  end
  
  def test_create_from_line
    # test empty
    line = ''
    r = Bio::ExportPred::Result.create_from_line(line)
    assert r
    assert_kind_of Bio::ExportPred::Result, r
    assert_equal false, r.predicted?
    
    line = 'metoo	RLE	6.44141	[a-met:M][a-leader:AVSTYNNTRRNGLRYVLKRR][a-hydrophobic:TILSVFAVICMLSL][a-spacer:NLSIFENNNNNYGFHCNKRH][a-RLE:FKSLAEA][a-tail:SPEEHNNLRSHSTSDPKKNEEKSLSDEINKCDMKKYTAEEINEMINSSNEFINRNDMNIIFSYVHESEREKFKKVEENIFKFIQSIVETYKIPDEYKMRKFKFAHFEMQGYALKQEKFLLEYAFLSLNGKLCERKKFKEVLEYVKREWIEFRKSMFDVWKEKLASEFREHGEMLNQKRKLKQHELDRRAQREKMLEEHSRGIFAKGYLGEVESETIKKKTEHHENVNEDNVEKPKLQQHKVQPPKVQQQKVQPPKSQQQKVQPPKSQQQKVQPPKVQQQKVQPPKVQKPKLQNQKGQKQVSPKAKGNNQAKPTKGNKLKKN]'
    r = Bio::ExportPred::Result.create_from_line(line)
    assert r
    assert_kind_of Bio::ExportPred::Result, r
    assert r.predicted?
    assert_equal 6.44141, r.score
  end
end
