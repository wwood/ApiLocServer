require File.dirname(__FILE__) + '/../test_helper'

class AminoAcidSequenceTest < ActiveSupport::TestCase
  fixtures :sequences
  
  # Replace this with your real tests.
  def test_bl2seq
    aa = AminoAcidSequence.find(1)
    aa2 = AminoAcidSequence.find(2)
    
    b = aa.blastp(aa2)
    assert b
    assert_equal 1, b.iterations[0].hits.length
    assert_equal 5.0e-11, b.iterations[0].hits[0].evalue
  end

  def test_tmhmm
    tmd = AminoAcidSequence.find(2)

    # test normal one
    t = tmd.tmhmm
    assert_equal 2, t.transmembrane_domains.length
    assert_equal 15, t.transmembrane_domains[0].start
    assert_equal 59, t.transmembrane_domains[1].stop

    # A more difficult one
    t = tmd.tmhmm(tmd.sequence, 3)
    assert_equal 2, t.transmembrane_domains.length
    assert_equal 15+3, t.transmembrane_domains[0].start
    assert_equal 59+3, t.transmembrane_domains[1].stop
  end

  def test_tmhmm_plus_signal_peptide
    # test normal one
    tmd = AminoAcidSequence.find(2)
    t = tmd.tmhmm_minus_signal_peptide
    assert_equal 2, t.transmembrane_domains.length
    assert_equal 15, t.transmembrane_domains[0].start
    assert_equal 59, t.transmembrane_domains[1].stop

    # A more difficult one, that has a SP and 2 TMDs
    tmd = AminoAcidSequence.find(5)
    t = tmd.tmhmm_minus_signal_peptide
    assert_equal 2, t.transmembrane_domains.length
    assert_equal 24+18, t.transmembrane_domains[0].start
    assert_equal 65+18, t.transmembrane_domains[1].stop
  end
end
