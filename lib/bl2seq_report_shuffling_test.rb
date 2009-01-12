# 
# To change this template, choose Tools | Templates
# and open the template in the editor.
 

$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'bl2seq_report_shuffling'

class Bl2seqReportShufflingTest < Test::Unit::TestCase
  include Bio::Blast::Bl2seq
  
  def test_shuffling
    
    assert(false, 'Assertion was false.')
    flunk "TODO: Write test"
    # assert_equal("foo", bar)
  end
end
