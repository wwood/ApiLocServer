require 'tandem_repeat_finder'

# A transcript
class TranscriptSequence < Sequence
  belongs_to :coding_region

  def at_content
    composition = to_bioruby_sequence.composition
    (composition['a']+composition['t']).to_f/
      (composition['g']+composition['c']+composition['a']+composition['t']).to_f
  end

  def to_bioruby_sequence
    to_return = Bio::Sequence.auto(Bio::Sequence::NA.new(sequence))
    to_return.entry_id = coding_region.string_id
    return to_return
  end

  def tandem_repeats
    return nil unless sequence and sequence.length > 0
    Bio::TandemRepeatFinder::Wrapper.new.run(sequence)
  end
end
