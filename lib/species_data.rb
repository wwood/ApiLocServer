class SpeciesData
  @@data = {
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
    splits = key.split(' ')
    raise unless splits.length == 2
    raise if @@data[splits[1]]
    @@data[splits[1]] = @@data[key]
  end

  SOURCE_VERSIONS = {
    'PlasmoDB' => '6.1',
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

  def protein_fasta_path
    s = @species_data
    "/home/ben/phd/data/#{s[:name]}/genome/#{s[:source]}/#{SOURCE_VERSIONS[s[:source]]}/"+
      s[:proteins_fasta_filename].call(SOURCE_VERSIONS[s[:source]])
  end
end
