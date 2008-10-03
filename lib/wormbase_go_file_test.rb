# 
# To change this template, choose Tools | Templates
# and open the template in the editor.
 

$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'wormbase_go_file'

module Bio
  class WormbaseGoFileTest < Test::Unit::TestCase
    def test_normal
      w = WormbaseGoFile.new('lib/testFiles/wormbaseGo.txt')
      assert_equal 3, w.genes.length
      
      assert_equal 'WBGene00000001', w.genes[0].name
      assert_equal %w(GO:0035014 GO:0005515 GO:0019901 GO:0005623 GO:0005942 GO:0040024 GO:0008340 GO:0008286).sort,
        w.genes[0].go_identifiers.sort
      
      assert_equal 'WBGene00000002', w.genes[1].name
      assert_equal %w(GO:0015171 GO:0016021 GO:0016020 GO:0005886 GO:0006865 GO:0006810).sort,
        w.genes[1].go_identifiers.sort
      
      assert_equal 'WBGene00000003', w.genes[2].name
      assert_equal %w(GO:0015171 GO:0016021 GO:0016020).sort,
        w.genes[2].go_identifiers.sort
      
    end
  end
end
