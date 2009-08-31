require 'bio'

class BlastsController < ApplicationController
  def index
  end

  def blast
    @input = params[:sequence]
    @input ||= params[:id]

    # parse the name of the organism that is being blasted against
    @output = blast_result(@input, params[:taxa], params[:program], params[:database])
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

    @blast_output = blast_result(@seq, params[:taxa], params[:program], params[:database])
  end


  private
  def blast_result(sequence, organism = 'apicomplexa', blast_program = nil, database=nil)
    organism ||= 'apicomplexa' # in case nil is passed here

    databases = {
      # species name => [blastn name, blastp name]
      'apicomplexa' => {
        'transcript' => 'apicomplexa.nucleotide.fa',
        'protein' => 'apicomplexa.protein.fa',
        'genome' => 'apicomplexa.genome.fa',
      },
      'yoelii' => {
        'transcript' => 'PyoeliiAnnotatedTranscripts_PlasmoDB-5.5.fasta',
        'protein' => 'PyoeliiAnnotatedProteins_PlasmoDB-5.5.fasta',
      }
    }
    blast_array = databases[organism]

    program_to_database_index = {
      'tblastx' => 'transcript',
      'tblastn' => 'transcript',
      'blastp' => 'protein',
      'blastn' => 'transcript',
      'blastx' => 'protein'
    }

    # work out if it is a protein sequence or a nucleotide sequence
    # meh. for the moment assume it is a transcript to be blasted
    seq = Bio::Sequence.auto(sequence)
    factory = nil
    database = nil if database == ''

    unless blast_program.nil? or program_to_database_index[blast_program].nil?
      if database.nil?
        factory = Bio::Blast.local(blast_program,
          "/blastdb/#{blast_array[program_to_database_index[blast_program]]}")
      else
        factory = Bio::Blast.local(blast_program,
          "/blastdb/#{blast_array[program_to_database_index[database]]}")
      end
    else
      if seq.moltype == Bio::Sequence::NA
        if database.nil?
          # default to protein
          factory = Bio::Blast.local('blastn', "/blastdb/#{blast_array['transcript']}")
        else
          # accept database as given
          factory = Bio::Blast.local('blastn', "/blastdb/#{blast_array[database]}")
        end
      elsif seq.moltype == Bio::Sequence::AA
        if database.nil?
          # default to protein
          factory = Bio::Blast.local('blastp', "/blastdb/#{blast_array['protein']}")
        else
          # accept database as given
          factory = Bio::Blast.local('tblastn', "/blastdb/#{blast_array[database]}")
        end
      end
    end

    factory.format = 0
    factory.filter = 'F'
    report = factory.query(seq)
    output = factory.output

    return output
  end
end
