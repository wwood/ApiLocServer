require "test/unit"
require 'orthomcl_defline_parser'

class OrthomclTest < Test::Unit::TestCase
  
  def test_regular
    line = '>aaeo|NP_212986 | OG30_10171 | elongation factor EF-G [Aquifex aeolicus VF5]'
    obj = OrthomclDeflineParser.parse_defline line
    assert_equal 'aaeo|NP_212986', obj.gene_id
    assert_equal 'OG30_10171', obj.group_id
    assert_equal 'elongation factor EF-G [Aquifex aeolicus VF5]', obj.annotation
  end
  
  def test_no_annotation
    line = '>lbic|eu2.Lbscf0004g07320 | OG30_14385 |'
    obj = OrthomclDeflineParser.parse_defline line
    assert_equal 'lbic|eu2.Lbscf0004g07320', obj.gene_id
    assert_equal 'OG30_14385', obj.group_id
    assert_equal '', obj.annotation
  end
  
  def test_with_spaces
    line = '>lbic|MRE_C4-methyl sterol oxidase | no_group | '
    obj = OrthomclDeflineParser.parse_defline line
    assert_equal 'lbic|MRE_C4-methyl sterol oxidase', obj.gene_id
    assert_equal 'no_group', obj.group_id
    assert_equal '', obj.annotation
  end
end