#require 'rubygems'
#gem 'bio'
require 'bio'
require 'bl2seq_runner'
require 'plasmo_a_p'
require 'export_pred'
require 'bl2seq_report_shuffling'
require 'signalp'
require 'radar'

class AminoAcidSequence < Sequence
  belongs_to :coding_region
  
  AMINO_ACIDS = Bio::AminoAcid::Data::NAMES.keys.select{|k| k.length == 1}.reach.upcase.retract
  
  def signal_p?
    return SignalSequence::SignalPWrapper.new.calculate(sequence).signal?
  end
  
  def signal_p
    return SignalSequence::SignalPWrapper.new.calculate(sequence)
  end
  
  # Blast this sequence against another amino acid sequence
  # Note this is the object AminoAcidSequence not a simple string
  def blastp(amino_acid_sequence_object, options = {})
    me = to_bioruby_sequence
    you = amino_acid_sequence_object.to_bioruby_sequence
    
    bl2seq = Bio::Blast::Bl2seq::Runner.new
    return bl2seq.bl2seq(me, you, options)
  end
  
  def to_bioruby_sequence
    to_return = Bio::Sequence.auto(Bio::Sequence::AA.new(sequence))
    to_return.entry_id = coding_region.string_id
    return to_return
  end
  
  def signalp_columns
    return SignalP.calculate_signal(sequence).all_results
  end
  
  alias_method :signal?, :signal_p?
  alias_method :signalp?, :signal_p?
  
  
  def targetp
    TargetPWrapper.new.targetp(sequence)
  end
  
  # Caches the SignalP output so it can be worked out faster
  def plasmo_a_p
    signal = coding_region.signalp_however
    Bio::PlasmoAP.new.calculate_score(sequence, 
      signal.classical_signal_sequence?, 
      signal.cleave(sequence))
  end
  
  def exportpred
    Bio::ExportPred::Wrapper.new.calculate(sequence)
  end
  
  def fasta
    ">#{coding_region.string_id}\n#{sequence}"
  end
  
  # return the amino_acid_sequence object and bl2seq report for 
  # the best bl2seq hit
  def best_bl2seq(other_amino_acid_sequences, evalue = nil)
    bl2seqs = other_amino_acid_sequences.collect do |aaseq|
      blastp(aaseq, evalue)
    end
    
    max_index = 0
    bl2seqs.each_with_index do |bl2seq, i|
      next if i==0#first wins by default
      max_challenge = bl2seq.best_evalue
      next if max_challenge.nil?
      max_incumbent = bl2seqs[max_index].best_evalue
      if max_incumbent.nil? or max_challenge < max_incumbent
        max_index = i
      end
    end
    
    return other_amino_acid_sequences[max_index], bl2seqs[max_index]
  end
  
  def tmhmm(seq=nil, offset=nil)
    seq ||= sequence
    result = TmHmmWrapper.new.calculate(seq)
    
    if offset
      result.transmembrane_domains.each do |tmd|
        tmd.start += offset
        tmd.stop += offset
      end
    end
    return result
  end
  
  def tmhmm_minus_signal_peptide
    result = signal_p
    if result.signal?
      return tmhmm(
        result.cleave(sequence),
        result.cleavage_site-1
      )
    else
      return tmhmm(sequence)
    end
  end

  def radar_repeats
    Bio::Radar::Wrapper.new.run(sequence)
  end

  # A very general purpose blast. Returns a list of the
  def blast(sequence_input = nil, organism = 'apicomplexa', blast_program = nil, database=nil, alignment_program='blast', blast_options = {}, sequence_name = nil)
    if sequence_input.nil?
      sequence_input = sequence
      sequence_name = "#{coding_region.string_id}"
    end
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
      },
      'toxoplasma' => {
        'transcript' => 'TgondiiME49AnnotatedTranscripts_ToxoDB-5.2.fasta',
        'protein' => 'TgondiiME49AnnotatedProteins_ToxoDB-5.2.fasta',
      },
      'babesia' => {
        'protein' => 'BabesiaWGS.fasta_with_names'
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
    database_to_default_programs = {
      'genome' => ['blastn', 'tblastn'],
      'transcript' => ['blastn', 'tblastn'],
      'protein' => ['blastx', 'blastp']
    }

    # work out if it is a protein sequence or a nucleotide sequence
    # meh. for the moment assume it is a transcript to be blasted
    seq = Bio::Sequence.auto(sequence_input)
    seq.entry_id = sequence_name
    factory = nil
    database = nil if database == ''

    factory_program = nil
    factory_database = nil

    # only use the blast_program given if it is defined and I understand it
    if blast_program and program_to_database_index[blast_program]
      # if no recognizable database is specified
      if database.nil? or blast_array[database].nil?
        # default to protein or transcript, depending on the program
        factory_program = blast_program
        factory_database = "/blastdb/#{blast_array[program_to_database_index[blast_program]]}"
      else
        logger.debug "Using what you expect: #{blast_program}, #{sequence_input}"
        factory_program = blast_program
        factory_database = "/blastdb/#{blast_array[database]}"
      end
    else
      if seq.moltype == Bio::Sequence::NA
        if database.nil? or blast_array[database].nil?
          # default to protein
          factory_program = 'blastn'
          factory_database = "/blastdb/#{blast_array['transcript']}"
        else
          # accept database as given. Choose the program to suit
          factory_program = database_to_default_programs[database][0]
          factory_database = "/blastdb/#{blast_array[database]}"
        end
      elsif seq.moltype == Bio::Sequence::AA
        if database.nil? or blast_array[database].nil?
          # default to protein
          factory_program = 'blastp'
          factory_database = "/blastdb/#{blast_array['protein']}"
        else
          # accept database as given
          factory_program = database_to_default_programs[database][1]
          factory_database = "/blastdb/#{blast_array[database]}"
        end
      end
    end

    raise if factory_program.nil?
    raise if factory_database.nil?
    raise Exception, "Database doesn't seem to exist! #{factory_database}" unless File.exist?(factory_database)

    output = nil
    if alignment_program == 'blast'
      factory = Bio::Blast.local(factory_program, factory_database, {'-a' => '2'}.merge(blast_options).to_a.flatten.join(' '))

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
