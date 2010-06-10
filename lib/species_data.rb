class SpeciesData
  @@data = {
    'Plasmodium falciparum' => {
      :name => 'Plasmodium falciparum',
      :source => 'PlasmoDB',
      :fasta_file_species_name => 'Plasmodium_falciparum_3D7',
      :sequencing_centre_abbreviation => 'psu',
    },
    'Plasmodium yoelii' => {
      :directory => 'yoelii',
      :name => 'Plasmodium yoelii',
      :sequencing_centre_abbreviation => 'tgr',
      :fasta_file_species_name => 'Plasmodium_yoelii_yoelii_str._17XNL',
      :proteins_fasta_filename => lambda {|version| "PyoeliiAnnotatedProteins_PlasmoDB-#{version}.fasta"},
      :transcripts_fasta_filename => lambda {|version| "PyoeliiAllTranscripts_PlasmoDB-#{version}.fasta"},
      :source => 'PlasmoDB'
    },
    'Plasmodium vivax' => {
      :name => 'Plasmodium vivax',
      :sequencing_centre_abbreviation => 'gb',
      :fasta_file_species_name => 'Plasmodium_vivax_SaI-1',
      :proteins_fasta_filename => lambda {|version| "PvivaxAnnotatedProteins_PlasmoDB-#{version}.fasta"},
      :source => 'PlasmoDB'
    },
    'Plasmodium berghei' => {
      :name => 'Plasmodium berghei',
      :sequencing_centre_abbreviation => 'psu',
      :fasta_file_species_name => 'Plasmodium_berghei_str._ANKA',
      :proteins_fasta_filename => lambda {|version| "PbergheiAnnotatedProteins_PlasmoDB-#{version}.fasta"},
      :transcripts_fasta_filename => lambda {|version| "PbergheiAllTranscripts_PlasmoDB-#{version}.fasta"},
      :source => 'PlasmoDB'
    },
    'Plasmodium chabaudi' => {
      :name => 'Plasmodium chabaudi',
      :sequencing_centre_abbreviation => 'psu',
      :fasta_file_species_name => 'Plasmodium_chabaudi_chabaudi',
      :proteins_fasta_filename => lambda {|version| "PchabaudiAnnotatedProteins_PlasmoDB-#{version}.fasta"},
      :source => 'PlasmoDB'
    },
    'Plasmodium knowlesi' => {
      :name => 'Plasmodium knowlesi',
      :sequencing_centre_abbreviation => 'psu',
      :fasta_file_species_name => 'Plasmodium_knowlesi_strain_H',
      :source => 'PlasmoDB'
    },
    'Neospora caninum' => {
      :name => 'Neospora caninum',
      :sequencing_centre_abbreviation => 'psu',
      :fasta_file_species_name => 'Neospora_caninum',
      :database_download_folder => 'NeosporaCaninum',
      :proteins_fasta_filename => lambda {|version| "NeosporaCaninumAnnotatedProteins_ToxoDB-#{version}.fasta"},
      :transcripts_fasta_filename => lambda {|version| "NeosporaCaninumAnnotatedTranscripts_ToxoDB-#{version}.fasta"},
      :source => 'ToxoDB'
    },
    'Toxoplasma gondii' => {
      :name => 'Toxoplasma gondii',
      :sequencing_centre_abbreviation => 'gb',
      :fasta_file_species_name => 'Toxoplasma_gondii_ME49',
      :gene_information_gzip_filename => lambda {|version| "TgondiiME49Gene_ToxoDB-#{version}.txt.gz"},
      :proteins_fasta_filename => lambda {|version| "TgondiiME49AnnotatedProteins_ToxoDB-#{version}.fasta"},
      :transcripts_fasta_filename => lambda {|version| "TgondiiME49AnnotatedTranscripts_ToxoDB-#{version}.fasta"},
      :gff_filename => lambda {|version| "TgondiiME49_ToxoDB-#{version}.gff"},
      :source => 'ToxoDB'
    },
    'Cryptosporidium parvum' => {
      :name => 'Cryptosporidium parvum',
      :sequencing_centre_abbreviation => 'gb',
      :fasta_file_species_name => 'Cryptosporidium_parvum',
      :proteins_fasta_filename => lambda {|version| "CparvumAnnotatedProteins_CryptoDB-#{version}.fasta"},
      :transcripts_fasta_filename => lambda {|version| "CparvumAnnotatedTranscripts_CryptoDB-#{version}.fasta"},
      :gff_filename => lambda {|version| "c_parvum_iowa_ii.gff"},
      :source => 'CryptoDB'
    },
    'Cryptosporidium hominis' => {
      :name => 'Cryptosporidium hominis',
      :sequencing_centre_abbreviation => 'gb',
      :fasta_file_species_name => 'Cryptosporidium_hominis',
      :proteins_fasta_filename => lambda {|version| "ChominisAnnotatedProteins_CryptoDB-#{version}.fasta"},
      :transcripts_fasta_filename => lambda {|version| "ChominisAnnotatedTranscripts_CryptoDB-#{version}.fasta"},
      :gff_filename => lambda {|version| "c_hominis_tu502.gff"},
      :source => 'CryptoDB'
    },
    'Cryptosporidium muris' => {
      :name => 'Cryptosporidium muris',
      :sequencing_centre_abbreviation => 'gb',
      :fasta_file_species_name => 'Cryptosporidium_muris',
      :proteins_fasta_filename => lambda {|version| "CmurisAnnotatedProteins_CryptoDB-#{version}.fasta"},
      :transcripts_fasta_filename => lambda {|version| "CmurisAnnotatedTranscripts_CryptoDB-#{version}.fasta"},
      :gff_filename => lambda {|version| "c_muris.gff"},
      :source => 'CryptoDB'
    },

    'Theileria annulata' => {
      :name => 'Theileria annulata',
    },
    'Theileria parva' => {
      :name => 'Theileria annulata',
    },
  }
  # Duplicate so both the species name and genus-species name work
  @@data.keys.each do |key|
    # name is full name of the species by default
    @@data[key][:name] ||= key

    # the species name without genus can also be used
    splits = key.split(' ')
    raise unless splits.length == 2
    raise if @@data[splits[1]]
    @@data[splits[1]] = @@data[key]
  end

  SOURCE_VERSIONS = {
    'PlasmoDB' => '6.4',
    'ToxoDB' => '6.0',
    'CryptoDB' => '4.3'
  }


  def initialize(nickname)
    @species_data = @@data[nickname] # try the full name
    @species_data ||= @@data[nickname.capitalize.gsub('_',' ')] #try replacing underscores
    if @species_data.nil? # try using just the second word
      splits = nickname.split(' ')
      if splits.length == 2
        @species_data = @@data[splits[1]]
      end
    end

    raise Exception, "Couldn't find species data for #{nickname}" unless @species_data
  end

  def method_missing(symbol)
    answer = @species_data[symbol]
    return answer unless answer.nil?
    super
  end

  # The path to the EuPathDB gene information table (stored as a gzip)
  def gene_information_gzfile_path
    gz = @species_data[:gene_information_gzip_filename]
    raise unless gz #a default will probably come around some time.
    "#{local_download_directory}/#{gz.call(version)}"
  end

  def version
    SOURCE_VERSIONS[@species_data[:source]]
  end

  def protein_fasta_filename
    if @species_data[:proteins_fasta_filename]
      return "#{@species_data[:proteins_fasta_filename].call(version)}"
    else
      return "#{one_word_name}AnnotatedProteins_#{database}-#{version}.fasta"
    end
  end

  def protein_fasta_path
    local_download_directory + '/' + protein_fasta_filename
  end
  
  def protein_blast_database_path
    "/blastdb/#{protein_fasta_filename}"
  end

  def transcript_fasta_filename
    if @species_data[:transcripts_fasta_filename]
      return "#{@species_data[:transcripts_fasta_filename].call(version)}"
    else
      return "#{one_word_name}AnnotatedTranscripts_#{database}-#{version}.fasta"
    end
  end

  def transcript_fasta_path
    "#{local_download_directory}/#{transcript_fasta_filename}"
  end
  
  def transcript_blast_database_path
    "/blastdb/#{transcript_fasta_filename}"
  end

  def gff_filename
    if @species_data[:gff_filename]
      return @species_data[:gff_filename].call(version)
    else
      return "#{one_word_name}_#{database}-#{version}.gff"
    end
  end

  def gff_path
    "#{local_download_directory}/#{gff_filename}"
  end

  def database
    databases = {
      /Plasmodium/ => 'PlasmoDB',
      /Toxo/ => 'ToxoDB',
      /Neospora/ => 'ToxoDB',
      /Cryptosporidium/ => 'CryptoDB'
    }
    db = nil
    databases.each do |regex, database|
      if @species_data[:name].match(regex)
        db = database
        break
      end
    end
    db
  end

  def eu_path_db_download_directory
    directories = {
      'PlasmoDB' => "http://plasmodb.org/common/downloads/release-#{SOURCE_VERSIONS['PlasmoDB']}",
      'ToxoDB' => "http://toxodb.org/common/downloads/release-#{SOURCE_VERSIONS['ToxoDB']}",
      'CryptoDB' => "http://cryptodb.org/common/downloads/release-#{SOURCE_VERSIONS['CryptoDB']}",
    }
    return "#{directories[database]}/#{one_word_name}"
  end

  # Plasmodium chabaudi => Pchabaudi
  def one_word_name
    return @species_data[:database_download_folder] unless @species_data[:database_download_folder].nil?
    splits = @species_data[:name].split(' ')
    raise unless splits.length == 2
    return "#{splits[0][0..0]}#{splits[1]}"
  end

  def local_download_directory
    s = @species_data
    "/home/ben/phd/data/#{s[:name]}/genome/#{s[:source]}/#{SOURCE_VERSIONS[s[:source]]}"
  end

  # an array of directory names. mkdir is called on each of them in order,
  # otherwise mkdir throws errors because there isn't sufficient folders
  # to build on.
  def directories_for_mkdir
    s = @species_data
    components = [
      '/home/ben/phd/data',
      s[:name],
      'genome',
      s[:source],
      SOURCE_VERSIONS[s[:source]]
    ]

    (0..components.length-1).collect do |i|
      components[0..i].join('/')
    end
  end
end
