require 'rubygems'
gem 'bio'
require 'bio'
require 'bl2seq_runner'

class AminoAcidSequence < Sequence
  belongs_to :coding_region
  
  def signal_p?
    return SignalP.calculate_signal?(sequence)
  end
  
  def signal_p
    return SignalP.calculate_signal(sequence)
  end
  
  # Blast this sequence against another amino acid sequence
  # Note this is the object AminoAcidSequence not a simple string
  def blastp(amino_acid_sequence_object)
    me = to_bioruby_sequence
    you = amino_acid_sequence_object.to_bioruby_sequence
    
    bl2seq = Bio::Blast::Bl2seq::Runner.new
    return bl2seq.bl2seq(me, you)
  end
  
  def to_bioruby_sequence
    to_return = Bio::Sequence.auto(Bio::Sequence::AA.new(sequence))
    to_return.entry_id = coding_region.string_id
    return to_return
  end
  
  def signalp_columns
    return SignalP.calculate_signal(sequence).all_results
  end
end
