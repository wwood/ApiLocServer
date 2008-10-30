# 
# To change this template, choose Tools | Templates
# and open the template in the editor.
 

$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'nls_db'

module Bio
  class NlsDbTest < Test::Unit::TestCase
    def test_extract
      xml = Bio::NlsDb::Xml.new(File.open('testFiles/nlsdb.generic.extract2.xml').read)
      entries = xml.entries
      assert_equal 2, entries.length
      assert_kind_of Bio::NlsDb::Entry, entries[0]
      
      e = entries[0]
      assert_equal 1, e.nls_db_id
      assert_equal "APKRKSGVSKC", e.signal
      assert_equal 'polyomaVP1', e.annotation
      assert_equal 'experimental', e.origin

      e = entries[1]
      assert_equal 2, e.nls_db_id
      assert_equal "APTKRKGS", e.signal
      assert_equal 'SV40()VP1', e.annotation
      assert_equal 'experimental', e.origin
    end
  end
end
