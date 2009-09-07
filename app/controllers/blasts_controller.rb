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

    # if the sequence is nucleotide, then try to get the protein sequence
    # associated with it. I'm mostly only interested in the protein sequence
    # being correct.
    seq2 = Bio::Sequence.auto(@seq)
    if seq2.moltype == Bio::Sequence::NA and 
        !%w(blastn tblastx blastx).include?(params[:program]) and
        !%w(transcript genome).include?(params[:database])
      # found a nucleotide sequence. What is the protein sequence attached
      # to it?
      rets = Bio::NCBI::REST::efetch(@genbank_id, {:db => 'nucleotide', :rettype => 'gb'})
      raise unless rets.class == String #problems. If they occur I'll deal with it then
      gb = Bio::GenBank.new(rets)
      cds = gb.features.select{|f| f.feature == 'CDS'}
      # for pseudogenes, they have nucleotide but no amino acid sequence.
      # I get confused by 2 or more different CDSs.
      if cds.length > 0
        raise unless cds.length == 1 and cds[0].assoc['translation']
        @seq = cds[0].assoc['translation']
      end
    end

    @blast_output = blast_result(@seq, params[:taxa], params[:program], params[:database])
  end


  private
  def blast_result(sequence, organism = 'apicomplexa', blast_program = nil, database=nil, alignment_program='blast')
    organism ||= 'apicomplexa' # in case nil is passed here
    alignment_program ||= 'blast'


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

    factory_program = nil
    factory_database = nil

    unless blast_program.nil? or program_to_database_index[blast_program].nil?
      if database.nil?
        # default to protein
        factory_program = blast_program
        factory_database = "/blastdb/#{blast_array[program_to_database_index[blast_program]]}"
      else
        # default to protein
        factory_program = blast_program
        factory_database = "/blastdb/#{blast_array[database]}"
      end
    else
      if seq.moltype == Bio::Sequence::NA
        if database.nil?
          # default to protein
          factory_program = 'blastn'
          factory_database = "/blastdb/#{blast_array['transcript']}"
        else
          # accept database as given
          factory_program = 'blastn'
          factory_database = "/blastdb/#{blast_array[database]}"
        end
      elsif seq.moltype == Bio::Sequence::AA
        if database.nil?
          # default to protein
          factory_program = 'blastp'
          factory_database = "/blastdb/#{blast_array['protein']}"
        else
          # accept database as given
          factory_program = 'blastn'
          factory_database = "/blastdb/#{blast_array[database]}"
        end
      end
    end

    raise if factory_program.nil?
    raise if factory_database.nil?
    raise Exception, "Database doesn't seem to exist! #{factory_database}" unless File.exist?(factory_database)

    output = nil
    if alignment_program == 'blast'
      factory = Bio::Blast.local(factory_program, factory_database)

      factory.format = 0
      factory.filter = 'F'

      #    # What are we doing again?
      logger.debug "BLAST search: database: #{database} program #{factory.inspect}"
      #    logger.debug("SEQUENCE: #{seq}")

      report = factory.query(seq)
      output = factory.output
    #elsif alignment_program == 'blat'
    else
      raise Exception, "I don't know how to handle this alignment program: '#{alignment_program}'"
    end

    return output
  end
end
