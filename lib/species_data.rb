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
      :proteins_fasta_filename => lambda {|version| "PknowlesiAnnotatedProteins_PlasmoDB-#{version}.fasta"},
      :source => 'PlasmoDB'
    },
    'Neospora caninum' => {
      :name => 'Neospora caninum',
      :sequencing_centre_abbreviation => 'psu',
      :fasta_file_species_name => 'Neospora_caninum',
      :proteins_fasta_filename => lambda {|version| "NeosporaCaninumAnnotatedProteins_ToxoDB-#{version}.fasta"},
      :source => 'ToxoDB'
    },
    'Cryptosporidium parvum' => {
      :name => 'Cryptosporidium parvum',
      :sequencing_centre_abbreviation => 'gb',
      :fasta_file_species_name => 'Cryptosporidium_parvum',
      :proteins_fasta_filename => lambda {|version| "CparvumAnnotatedProteins_CryptoDB-#{version}.fasta"},
      :source => 'CryptoDB'
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
    'PlasmoDB' => '6.2',
    'ToxoDB' => '5.2',
    'CryptoDB' => '4.2'
  }


  def initialize(nickname)
    @species_data = @@data[nickname]
    @species_data ||= @@data[nickname.capitalize.gsub('_',' ')]

    raise Exception, "Couldn't find species data for #{nickname}" unless @species_data
  end

  def method_missing(symbol)
    answer = @species_data[symbol]
    return answer unless answer.nil?
    raise
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

  def transcript_fasta_filename
    if @species_data[:transcript_fasta_filename]
      return "#{@species_data[:transcript_fasta_filename].call(version)}"
    else
      return "#{one_word_name}AnnotatedTranscripts_#{database}-#{version}.fasta"
    end
  end

  def transcript_fasta_path
    "#{local_download_directory}/#{transcript_fasta_filename}"
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
    splits = @species_data[:name].split(' ')
    raise unless splits.length == 2
    return "#{splits[0][0..0]}#{splits[1]}"
  end

  def local_download_directory
    s = @species_data
    "/home/ben/phd/data/#{s[:name]}/genome/#{s[:source]}/#{SOURCE_VERSIONS[s[:source]]}"
  end
end
