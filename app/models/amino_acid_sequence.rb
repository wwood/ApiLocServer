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
    if block_given?
      ">#{yield coding_region}\n#{sequence}"
    else
      ">#{coding_region.string_id}\n#{sequence}"
    end
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

  def best_blast_hit(organism='falciparum')
    blast_output = BlastHelper.new.blast(sequence, organism)
    Bio::Blast.reports(blast_output) do |report|
      best_hit = report.hits[0]
      return nil unless best_hit
      return best_hit.target_id
    end
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

  def blast(sequence_input = nil, organism = 'apicomplexa', blast_program = nil, database=nil, alignment_program='blast', blast_options = {}, sequence_name = nil)
    require 'blast_helper'
    
    if sequence_input.nil?
      sequence_input = sequence
      sequence_name = "#{coding_region.string_id}"
    end

    logger.debug("blast options: #{
      [sequence_input, organism, blast_program, database,
      alignment_program, blast_options, sequence_name].inspect}")

    BlastHelper.new.blast(sequence_input, organism, blast_program, database,
      alignment_program, blast_options, sequence_name)
  end
end
