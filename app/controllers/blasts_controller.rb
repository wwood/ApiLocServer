require 'bio'

class BlastsController < ApplicationController
  def index
  end

  def blast
    @input = params[:sequence]
    @input ||= params[:id]

    # parse the name of the organism that is being blasted against
    @organism = params[:taxa]
    @organism ||= 'apicomplexa'

    databases = {
      # species name => [blastn name, blastp name]
      'apicomplexa' => ['apicomplexa.nucleotide.fa', 'apicomplexa.protein.fa'],
      'yoelii' => ['PyoeliiAnnotatedTranscripts_PlasmoDB-5.5.fasta', 'PyoeliiAnnotatedProteins_PlasmoDB-5.5.fasta']
    }
    blast_array = databases[@organism]

    # work out if it is a protein sequence or a nucleotide sequence
    # meh. for the moment assume it is a transcript to be blasted
    seq = Bio::Sequence.auto(@input)
    factory = nil
    if seq.moltype == Bio::Sequence::NA
      factory = Bio::Blast.local('blastn', "/blastdb/#{blast_array[0]}")
    elsif seq.moltype == Bio::Sequence::AA
      logger.debug "using protein!"
      factory = Bio::Blast.local('blastp', "/blastdb/#{blast_array[1]}")
    end

    factory.format = 0
    factory.filter = 'F'
    @report = factory.query(seq)
    @output = factory.output
  end
end
