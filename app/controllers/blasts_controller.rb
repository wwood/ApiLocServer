require 'bio'

class BlastsController < ApplicationController
  def index
  end

  def blast
    @input = params[:sequence]
    @input ||= params[:id]

    # parse the name of the organism that is being blasted against
    @output = blast_result(@input, params[:taxa])
  end

  def blast_genbank
    @genbank_id = params[:seq]
    @genbank_id ||= params[:id]

    unless @genbank_id
      flash[:error] = "No genbank identifier!"
      return
    end
    
    rets = Bio::NCBI::REST::efetch(@genbank_id, {:db => 'sequences', :rettype => 'fasta'})

    # Not sure what is returned exactly. I believe a string
    # is the most up to date.
    str = rets

    # make str = rets[0] unless rets is a String (this is old code?)
    unless rets.class == String
      unless rets.length == 1
        flash[:error] = "#{rets.length} sequences found! Expected 1."
        return
      end
      str = rets[0]
    end

    fasta = Bio::FastaFormat.new(str)
    @seq = fasta.seq
    @name = fasta.definition

    @blast_output = blast_result(@seq, params[:taxa], params[:program])
  end


  private
  def blast_result(sequence, organism = 'apicomplexa', blast_program = nil)
    organism ||= 'apicomplexa' # in case nil is passed here

    databases = {
      # species name => [blastn name, blastp name]
      'apicomplexa' => ['apicomplexa.nucleotide.fa', 'apicomplexa.protein.fa'],
      'yoelii' => ['PyoeliiAnnotatedTranscripts_PlasmoDB-5.5.fasta', 'PyoeliiAnnotatedProteins_PlasmoDB-5.5.fasta']
    }
    blast_array = databases[organism]

    program_to_database_index = {
      'tblastx' => 0,
      'tblastn' => 0,
      'blastp' => 1,
      'blastn' => 0
    }

    # work out if it is a protein sequence or a nucleotide sequence
    # meh. for the moment assume it is a transcript to be blasted
    seq = Bio::Sequence.auto(sequence)
    factory = nil

    unless blast_program.nil? or program_to_database_index[blast_program].nil?
      factory = Bio::Blast.local(blast_program,
        "/blastdb/#{blast_array[program_to_database_index[blast_program]]}")
    else
      if seq.moltype == Bio::Sequence::NA
        factory = Bio::Blast.local('blastn', "/blastdb/#{blast_array[0]}")
      elsif seq.moltype == Bio::Sequence::AA
        logger.debug "using protein!"
        factory = Bio::Blast.local('blastp', "/blastdb/#{blast_array[1]}")
      end
    end

    factory.format = 0
    factory.filter = 'F'
    report = factory.query(seq)
    output = factory.output

    return output
  end
end
