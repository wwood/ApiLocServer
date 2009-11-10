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




    databases = {
      'apicomplexa' => {
        'transcript' => 'apicomplexa.nucleotide.fa',
        'protein' => 'apicomplexa.protein.fa',
        'genome' => 'apicomplexa.genome.fa',
      },
      'yoelii' => {
        'transcript' => "PyoeliiAllTranscripts_PlasmoDB-#{PLASMODB_VERSION}.fasta",
        'protein' => "PyoeliiAnnotatedProteins_PlasmoDB-#{PLASMODB_VERSION}.fasta",
        'genome' => "PyoeliiGenomic_PlasmoDB-#{PLASMODB_VERSION}.fasta",
      },
      'falciparum' => {
        'transcript' => "PfalciparumAnnotatedTranscripts_PlasmoDB-#{PLASMODB_VERSION}.fasta",
        'protein' => "PfalciparumAnnotatedProteins_PlasmoDB-#{PLASMODB_VERSION}.fasta",
        'genome' => "PfalciparumGenomic_PlasmoDB-#{PLASMODB_VERSION}.fasta",
      },
      'knowlesi' => {
        'transcript' => "PknowlesiAllTranscripts_PlasmoDB-#{PLASMODB_VERSION}.fasta",
        'protein' => "PknowlesiAnnotatedProteins_PlasmoDB-#{PLASMODB_VERSION}.fasta",
        'genome' => "PknowlesiGenomic_PlasmoDB-#{PLASMODB_VERSION}.fasta",
      },
      'toxoplasma' => {
        'transcript' => "TgondiiME49AnnotatedTranscripts_ToxoDB-#{TOXODB_VERSION}.fasta",
        'protein' => "TgondiiME49AnnotatedProteins_ToxoDB-#{TOXODB_VERSION}.fasta",
      },
      'babesia' => {
        'protein' => 'BabesiaWGS.fasta_with_names'
      },
      'neospora' => {
        'protein' => "NeosporaCaninumAnnotatedProteins_ToxoDB-#{TOXODB_VERSION}.fasta",
        'transcript' => "NeosporaCaninumAnnotatedTranscripts_ToxoDB-#{TOXODB_VERSION}.fasta",
        'genome' => "NeosporaCaninumGenomic_ToxoDB-#{TOXODB_VERSION}.fasta",
      },
      'crypto' => {
        'protein' => "CparvumAnnotatedProteins_CryptoDB-#{CRYPTODB_VERSION}.fasta",
        'transcript' => "CparvumAnnotatedTranscripts_CryptoDB-#{CRYPTODB_VERSION}.fasta",
        'genome' => "CparvumGenomic_CryptoDB-#{CRYPTODB_VERSION}.fasta",
      },
      'theileria' => {
        'protein' => 'theileria.pep'
      },
      'berghei' => {
        'transcript' => "PbergheiAllTranscripts_PlasmoDB-#{PLASMODB_VERSION}.fasta",
        'protein' => "PbergheiAnnotatedProteins_PlasmoDB-#{PLASMODB_VERSION}.fasta",
        'genome' => "PbergheiGenomic_PlasmoDB-#{PLASMODB_VERSION}.fasta"
      },
      'chabaudi' => {
        'transcript' => "PchabaudiAnnotatedTranscripts_PlasmoDB-#{PLASMODB_VERSION}.fasta",
        'protein' => "PchabaudiAnnotatedProteins_PlasmoDB-#{PLASMODB_VERSION}.fasta",
        'genome' => "PchabaudiGenomic_PlasmoDB-#{PLASMODB_VERSION}.fasta"
      }
    }
    #    p organism
    #    p databases
    blast_array = databases[organism]
    #    p blast_array

    # Some organisms don't exist yet. Reject these
    unless organism and organism
      raise Exception, "Unknown database: #{organism}" if blast_array.nil?
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
      #      logger.debug "BLAST search: database: #{database} program #{factory.inspect}"
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
