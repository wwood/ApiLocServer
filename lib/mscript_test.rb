# To change this template, choose Tools | Templates
# and open the template in the editor.

$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'rubygems'
require 'test/unit'
require 'mscript'
require 'test/zentest_assertions' #for capturing stdout
require 'tempfile'

# this all got too hard because I wasn't sure how to put it into a test
# environment, and maybe it doesn't quite need testing anyway

class MscriptTest < Test::Unit::TestCase
  def test_are_genes_enzymes_or_lethal?
    # make sure the capturing stdout works
    out, err = util_capture do
      puts 'oute'
    end
    assert_equal "oute\n", out

    # test that it outputs the correct thing for an easy gene
    #    Tempfile.new('mscript_test') do |tempfile|
    #      tempfile.puts
    #    end
  end
end
