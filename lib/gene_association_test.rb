# To change this template, choose Tools | Templates
# and open the template in the editor.

$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'gene_association'
require 'tempfile'

class GeneAssociationTest < Test::Unit::TestCase
  def test_simple
    line = 'SGD	S000000289	AAC3		GO:0006810	SGD_REF:S000124038	IEA	SP_KW:KW-0813	P	Mitochondrial inner membrane ADP/ATP translocator, exchanges cytosolic ADP for mitochondrially synthesized ATP	YBR085W|ANC3	gene	taxon:4932	20090112	UniProtKB'
    
    assert_equal 15, line.split("\t").length
    assoc = Bio::GeneAssociation.new('SGD	S000000289	AAC3		GO:0006810	SGD_REF:S000124038	IEA	SP_KW:KW-0813	P	Mitochondrial inner membrane ADP/ATP translocator, exchanges cytosolic ADP for mitochondrially synthesized ATP	YBR085W|ANC3	gene	taxon:4932	20090112	UniProtKB')

    entries = assoc.entries
    assert_equal 1, entries.length
    assert_equal 'AAC3', entries[0].gene_name
    assert_equal %w(YBR085W ANC3), entries[0].alternate_gene_ids
    assert_equal 'GO:0006810', entries[0].go_identifier
    assert_equal 'biological_process', entries[0].aspect
    assert_equal 'S000000289', entries[0].primary_id
  end

  def test_gzip2
    gzip_filename = '/tmp/gzipTest12345532'
    writer = Zlib::GzipWriter.open(gzip_filename)
    writer.puts 'SGD	S000000289	AAC3		GO:0006810	SGD_REF:S000124038	IEA	SP_KW:KW-0813	P	Mitochondrial inner membrane ADP/ATP translocator, exchanges cytosolic ADP for mitochondrially synthesized ATP	YBR085W|ANC3	gene	taxon:4932	20090112	UniProtKB'
    writer.close

    count = 0
    Bio::GzipAndFilterGeneAssociation.foreach(gzip_filename, '.') do |c|
      count += 1
      assert_kind_of Bio::GeneOntologyEntry, c
      assert_equal 'GO:0006810', c.go_identifier
    end
    assert_equal 1, count
  end

  def test_gzip_grep
    gzip_filename = '/tmp/gzipTest12345532'
    writer = Zlib::GzipWriter.open(gzip_filename)
    writer.puts 'SGD	S000000289	AAC3		GO:0006810	SGD_REF:S000124038	IEA	SP_KW:KW-0813	P	Mitochondrial inner membrane ADP/ATP translocator, exchanges cytosolic ADP for mitochondrially synthesized ATP	YBR085W|ANC3	gene	taxon:4932	20090112	UniProtKB'
    writer.puts 'SGD	S000000289	AAC1		GO:0006810	SGD_REF:S000124038	IEA	SP_KW:KW-0813	P	Mitochondrial inner membrane ADP/ATP translocator, exchanges cytosolic ADP for mitochondrially synthesized ATP	YBR085W|ANC3	gene	taxon:4931	20090112	UniProtKB'
    writer.puts 'SGD	S000000289	AAC2		GO:0006810	SGD_REF:S000124038	IEA	SP_KW:KW-0813	P	Mitochondrial inner membrane ADP/ATP translocator, exchanges cytosolic ADP for mitochondrially synthesized ATP	YBR085W|ANC3	gene	taxon:4931	20090112	UniProtKB'
    writer.close

    count = 0
    Bio::GzipAndFilterGeneAssociation.foreach(gzip_filename, "\ttaxon:4931\t") do |c|
      count += 1
      assert_kind_of Bio::GeneOntologyEntry, c
      assert_equal "AAC#{count}", c.gene_name
    end
    assert_equal 2, count
  end
end
