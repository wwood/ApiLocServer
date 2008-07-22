

$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'bl2seq_runner.rb'
require 'rubygems'
gem 'bio'
require 'bio'

class Bl2seqRunnerTest < Test::Unit::TestCase
  def test_simple
    
    # Test one without any hits
    s1 = Bio::Sequence.new('AA')
    s1.entry_id = 'seq1'
    
    s2 = Bio::Sequence.new('GG')
    s2.entry_id = 'seq2'
    
    runner = Bio::Blast::Bl2seq::Runner.new
    bl2seq = runner.bl2seq(s1, s2)
    assert bl2seq
    assert_equal 0, bl2seq.iterations[0].hits.length
    
    
    
    # test with only 1 good hits
    s1 = Bio::Sequence.new('TSPFIIIINIIDIFHHSYLLYFIFSFNFITIIFFYYYVEKSIFIFIFIIKYTFSYHIIIFVFQMFQFI')
    s1.entry_id = 'seq1'
    
    s2 = Bio::Sequence.new('TSPFIIIINIIDIFHHSYLLYFIFSFNFITIIFFYYYVEKSIFIFIFIIKYTFSYHIIIFVFQMFQFI')
    s2.entry_id = 'seq2'
    
    
    runner = Bio::Blast::Bl2seq::Runner.new
    bl2seq = runner.bl2seq(s1, s2)
    hits = bl2seq.iterations
    assert hits 
    assert_equal 1, bl2seq.iterations[0].hits.length
    
  end
end
