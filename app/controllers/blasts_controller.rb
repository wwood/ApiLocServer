require 'bio'

class BlastsController < ApplicationController
  def index
  end

  def blast
    @input = params[:sequence]
    @input ||= params[:id]

    # work out if it is a protein sequence or a nucleotide sequence
    # meh. for the moment assume it is a transcript to be blasted
    seq = Bio::Sequence.auto(@input)
    factory = nil
    if seq.moltype == Bio::Sequence::NA
      factory = Bio::Blast.local('blastn', '/blastdb/apicomplexa.nucleotide.fa')
    elsif seq.moltype == Bio::Sequence::AA
      factory = Bio::Blast.local('blastp', '/blastdb/apicomplexa.protein.fa')
    end

    factory.format = 0
    factory.filter = 'F'
    @report = factory.query(seq)
    @output = factory.output
  end
end
