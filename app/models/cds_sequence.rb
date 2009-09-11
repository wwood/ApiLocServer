require 'nucleotide_sequence_methods'

# Cds sequences are the sequences which correspond to the codons that encode
# the amino acids, excluding the 3' and 5' UTR.
class CdsSequence < TranscriptSequence
  belongs_to :coding_region
  include NucleotideSequenceMethods
end
