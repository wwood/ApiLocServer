# To change this template, choose Tools | Templates
# and open the template in the editor.

$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'eu_path_d_b_gene_information_table'

class EuPathDBGeneInformationTableTest < Test::Unit::TestCase
  def test_gene_splitting
    eu = EuPathDBGeneInformationTable.new(File.open('testFiles/eupathGeneInformation.txt','r'))
    genes = %w(TGME49_000010 TGME49_000110)
    total = 0
    eu.each_with_index do |info, i|
      total += 1
      assert_equal genes[i], info.get_info('ID')
    end
    assert_equal 2, total
  end

  def test_table
    eu = EuPathDBGeneInformationTable.new(File.open('testFiles/eupathGeneInformation.txt','r'))
    genes = [
      {
      'Type' => 'exon',
      'Start' => '2230843',
      'End' => '2232576'
      },
      {
      'Type' => 'intron',
      'Start' => '2232577',
      'End' => '2232920'
      },
      {
      'Type' => 'exon',
      'Start' => '2232921',
      'End' => '2234577'
      },
    ]
    assert_equal genes, eu.to_a[0].get_table('Gene Model')
  end

  def test_last_entry
    eu = EuPathDBGeneInformationTable.new(File.open('testFiles/eupathGeneInformation.txt','r'))
    a = eu.to_a
    first = a[0]
    last = a[1]
    assert_equal [{'Product' => 'hypothetical protein, conserved'}],
      last.get_table('Product')
    assert_equal [{'Product' => 'hypothetical protein'}],
      first.get_table('Product')
  end
  
  def test_alias_brackets
    eu = EuPathDBGeneInformationTable.new(File.open('testFiles/eupathGeneInformation.txt','r'))
    genes = %w(TGME49_000010 TGME49_000110)
    total = 0
    eu.each_with_index do |info, i|
      total += 1
      assert_equal genes[i], info['ID']
    end
    assert_equal 2, total
  end
end
