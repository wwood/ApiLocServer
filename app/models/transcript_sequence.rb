require 'nucleotide_sequence_methods'

# A transcript
class TranscriptSequence < Sequence
  belongs_to :coding_region
  include NucleotideSequenceMethods
end
