# To change this template, choose Tools | Templates
# and open the template in the editor.

class BlastHelper
  PLASMODB_VERSION = 6.1
  CRYPTODB_VERSION = 4.2
  TOXODB_VERSION = 5.2

  # An opinionated blast method
  def blast(sequence_input = nil, organism = 'apicomplexa', blast_program = nil, database=nil, alignment_program='blast', blast_options = {}, sequence_name = nil)
    organism = nil if organism and organism.strip == ''
    organism ||= 'apicomplexa' # in case nil is passed here
    alignment_program ||= 'blast'

    species_data = SpeciesData.new(organism)

    # Some organisms don't exist yet. Reject these
    unless organism and organism
      raise Exception, "Unknown database: #{organism}" if species_data.nil?
    end

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

    # Am I dealing with a sensible database here?
    sensible_database = false
    unless database.nil?
      sensible_database = %(protein transcript genome).include?(database)
    end

    # only use the blast_program given if it is defined and I understand it
    if blast_program and program_to_database_index[blast_program]
      factory_program = blast_program
      factory_database = species_data.send("#{program_to_database_index[blast_program]}_blast_database_path".to_sym)
    else
      if seq.moltype == Bio::Sequence::NA
        if sensible_database
          # accept database as given. Choose the program to suit
          factory_program = database_to_default_programs[database][0]
          factory_database = species_data.send("#{database}_blast_database_path".to_sym)
        else
          # default to blastn search against transcripts
          factory_program = 'blastn'
          factory_database = species_data.transcript_blast_database_path
        end
      elsif seq.moltype == Bio::Sequence::AA
        if sensible_database
          # accept database as given
          factory_program = database_to_default_programs[database][1]
          factory_database = species_data.send("#{database}_blast_database_path".to_sym)
        else
          # default to protein
          factory_program = 'blastp'
          factory_database = species_data.protein_blast_database_path
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

      # What are we doing again?
      logger.debug "BLAST search: database: #{database} program #{factory.inspect}"
      logger.debug("SEQUENCE: #{seq}")

      report = factory.query(seq)
      output = factory.output
      #elsif alignment_program == 'blat'
    else
      raise Exception, "I don't know how to handle this alignment program: '#{alignment_program}'"
    end

    return output
  end
end
