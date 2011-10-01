require 'localisation_spreadsheet'

class Species < ActiveRecord::Base
  FALCIPARUM = 'Plasmodium falciparum'
  FALCIPARUM_NAME = FALCIPARUM
  PLASMODIUM_FALCIPARUM_NAME = FALCIPARUM
  VIVAX = 'Plasmodium vivax'
  VIVAX_NAME = VIVAX
  BERGHEI_NAME = 'Plasmodium berghei'
  PLASMODIUM_BERGHEI_NAME = BERGHEI_NAME
  YOELII_NAME = 'Plasmodium yoelii'
  CHABAUDI_NAME = 'Plasmodium chabaudi'
  KNOWLESI_NAME = 'Plasmodium knowlesi'
  THEILERIA_PARVA = 'Theileria parva'
  THEILERIA_PARVA_NAME = THEILERIA_PARVA
  THEILERIA_ANNULATA_NAME = 'Theileria annulata'
  TOXOPLASMA_GONDII = 'Toxoplasma gondii'
  TOXOPLASMA_GONDII_NAME = TOXOPLASMA_GONDII
  NEOSPORA_CANINUM_NAME = 'Neospora caninum'
  ELEGANS_NAME = 'Caenorhabditis elegans'
  EIMERIA_TENELLA_NAME = 'Eimeria tenella'
  BABESIA_BOVIS_NAME = 'Babesia bovis'
  YEAST_NAME= 'Saccharomyces cerevisiae'
  MOUSE_NAME = 'Mus musculus'
  DROSOPHILA_NAME= 'Drosophila melanogaster'
  CRYPTOSPORIDIUM_HOMINIS_NAME = 'Cryptosporidium hominis'
  CRYPTOSPORIDIUM_PARVUM_NAME = 'Cryptosporidium parvum'
  CRYPTOSPORIDIUM_MURIS_NAME = 'Cryptosporidium muris'
  HUMAN_NAME = 'Homo sapiens'
  ARABIDOPSIS_NAME = 'Arabidopsis thaliana'
  TETRAHYMENA_NAME = 'Tetrahymena thermophila'
  CHLAMYDOMONAS_NAME = 'Chlamydomonas reinhardtii'
  DANIO_RERIO_NAME = 'Danio rerio'
  RICE_NAME = 'Oryza sativa'
  TOBACCO_NAME = 'Nicotiana alata'
  TOMATO_NAME = 'Lycopersicon'
  SOYBEAN_NAME = 'Glycine max'
  BARLEY_NAME = 'Hordeum vulgar'
  PLANKTON_NAME = 'Ostreococcus tauri'
  MOSS_NAME = 'Physcomitrella patens'
  CASTOR_BEAN_NAME = 'Ricinus communis'
  POMBE_NAME = 'Schizosaccharomyces pombe'
  RAT_NAME = 'Rattus norvegicus'
  DICTYOSTELIUM_DISCOIDEUM_NAME = 'Dictyostelium discoideum'
  TRYPANOSOMA_BRUCEI_NAME = 'Trypanosoma brucei'
  DICTYOSTELIUM_NAME = DICTYOSTELIUM_DISCOIDEUM_NAME
  TBRUCEI_NAME = TRYPANOSOMA_BRUCEI_NAME
  
  # Not ever uploaded as a species, just a useful constant
  OTHER_SPECIES = 'Other species placeholder'
  
  # Technically, this is Apicomplexans that don't exist in any EuPathDB
  # database
  UNSEQUENCED_APICOMPLEXANS = [
    'Plasmodium gallinaceum',
    'Plasmodium cynomolgi',
    'Plasmodium malariae',
    'Sarcocystis neurona',
    'Sarcocystis muris',
    'Theileria lestoquardi',
    'Babesia bigemina',
    'Babesia divergens',
    'Babesia microti',
    'Babesia gibsoni',
    'Babesia equi',
    'Eimeria ascervulina',
    'Eimeria maxima',
  ]
  
  has_many :scaffolds, :dependent => :destroy
  has_many :localisations, :dependent => :destroy
  has_many :developmental_stages, :dependent => :destroy
  
  ORTHOMCL_THREE_LETTERS = {
    FALCIPARUM => 'pfa',
    ELEGANS_NAME => 'cel',
    TOXOPLASMA_GONDII_NAME => 'tgo',
    YEAST_NAME=> 'sce',
    MOUSE_NAME=> 'mmu',
    DROSOPHILA_NAME=> 'dme'
  }
  
  ORTHOMCL_FOUR_LETTERS = {
    DANIO_RERIO_NAME => 'drer',
    RICE_NAME => 'osat',
    CHLAMYDOMONAS_NAME => 'crei',
    TETRAHYMENA_NAME => 'tthe',
    FALCIPARUM => 'pfal',
    VIVAX_NAME => 'pviv',
    BERGHEI_NAME => 'pber',
    YOELII_NAME => 'pyoe',
    KNOWLESI_NAME => 'pkno',
    CHABAUDI_NAME => 'pcha',
    CRYPTOSPORIDIUM_HOMINIS_NAME => 'chom',
    CRYPTOSPORIDIUM_PARVUM_NAME => 'cpar',
    CRYPTOSPORIDIUM_MURIS_NAME => 'cmur',
    BABESIA_BOVIS_NAME => 'bbov',
    THEILERIA_PARVA_NAME => 'tpar',
    THEILERIA_ANNULATA_NAME => 'tann',
    ELEGANS_NAME => 'cele',
    TOXOPLASMA_GONDII_NAME => 'tgon',
    NEOSPORA_CANINUM_NAME => 'ncan',
    YEAST_NAME => 'scer',
    POMBE_NAME => 'spom',
    MOUSE_NAME => 'mmus',
    RAT_NAME => 'rnor',
    DROSOPHILA_NAME => 'dmel',
    NEOSPORA_CANINUM_NAME => 'ncan',
    ARABIDOPSIS_NAME => 'atha',
    HUMAN_NAME => 'hsap',
    DICTYOSTELIUM_DISCOIDEUM_NAME => 'ddis',
    TRYPANOSOMA_BRUCEI_NAME => 'tbru',
  }
  
  ORTHOMCL_CURRENT_LETTERS = ORTHOMCL_FOUR_LETTERS
  
  SPECIES_PREFIXES = {
    FALCIPARUM_NAME => 'Pf',
    TOXOPLASMA_GONDII_NAME => 'Tg',
  }
  
  PLASMODB_SPECIES_NAMES = [
  FALCIPARUM,
  VIVAX,
  BERGHEI_NAME,
  YOELII_NAME,
  CHABAUDI_NAME,
  KNOWLESI_NAME,
  ]
  
  TOXODB_SPECIES_NAMES = [
  TOXOPLASMA_GONDII_NAME,
  NEOSPORA_CANINUM_NAME,
  EIMERIA_TENELLA_NAME,
  ]
  
  CRYPTODB_SPECIES_NAMES = [
  CRYPTOSPORIDIUM_HOMINIS_NAME,
  CRYPTOSPORIDIUM_PARVUM_NAME,
  CRYPTOSPORIDIUM_MURIS_NAME
  ]
  
  PIROPLASMADB_SPECIES_NAMES = [
  BABESIA_BOVIS_NAME,
  THEILERIA_ANNULATA_NAME,
  THEILERIA_PARVA_NAME,
  ]
  
  APICOMPLEXAN_NAMES = [
  PLASMODB_SPECIES_NAMES,
  TOXODB_SPECIES_NAMES,
  CRYPTODB_SPECIES_NAMES,
  PIROPLASMADB_SPECIES_NAMES,
  ].flatten
  
  named_scope :apicomplexan, {
    :conditions => "species.name in #{[Species::APICOMPLEXAN_NAMES, UNSEQUENCED_APICOMPLEXANS].flatten.to_sql_in_string}"
  }
  named_scope :not_apicomplexan, {
    :conditions => "species.name not in #{[Species::APICOMPLEXAN_NAMES, UNSEQUENCED_APICOMPLEXANS].flatten.to_sql_in_string}"
  }
  named_scope :sequenced_apicomplexan, {
    :conditions => "species.name in #{[Species::APICOMPLEXAN_NAMES].to_sql_in_string}"
  }
  
  PLANTAE_NAME = 'Plantae'
  UNIKONT_NAME = 'Unikont'
  APICOMPLEXA_NAME = 'Apicomplexa'
  METAZOA_NAME = 'Metazoa'
  FUNGI_NAME = 'Fungi'
  AMOEBOZOA_NAME = 'Amoebozoa'
  EXCAVATA_NAME = 'Excavata'
  
  # Categorise species of interest into broad taxanomic
  # classes
  THREE_WAY_TAXONOMY_DEFINITIONS = {
    PLANTAE_NAME => [
    RICE_NAME,
    CHLAMYDOMONAS_NAME,
    ARABIDOPSIS_NAME,
    ],
    UNIKONT_NAME => [
    DANIO_RERIO_NAME,
    ELEGANS_NAME,
    YEAST_NAME,
    POMBE_NAME,
    MOUSE_NAME,
    RAT_NAME,
    DROSOPHILA_NAME,
    HUMAN_NAME,
    DICTYOSTELIUM_DISCOIDEUM_NAME,
    ],
    APICOMPLEXA_NAME => APICOMPLEXAN_NAMES,
  }
  NAME_TO_KINGDOM = {}
  THREE_WAY_TAXONOMY_DEFINITIONS.each do |kingdom, names|
    names.each do |species_name|
      NAME_TO_KINGDOM[species_name] = kingdom
    end
  end
  
  # The same as THREE_WAY_TAXONOMY_DEFINITIONS except separate
  # Unikont into fungi and metazoa.
  FOUR_WAY_TAXONOMY_DEFINITIONS = {
    PLANTAE_NAME => [
    RICE_NAME,
    CHLAMYDOMONAS_NAME,
    ARABIDOPSIS_NAME,
    ],
    METAZOA_NAME => [
    DANIO_RERIO_NAME,
    ELEGANS_NAME,
    MOUSE_NAME,
    RAT_NAME,
    DROSOPHILA_NAME,
    HUMAN_NAME,
    ],
    FUNGI_NAME => [
    YEAST_NAME,
    POMBE_NAME,
    ],
    APICOMPLEXA_NAME => APICOMPLEXAN_NAMES,
    EXCAVATA_NAME => [TRYPANOSOMA_BRUCEI_NAME],
    AMOEBOZOA_NAME => [DICTYOSTELIUM_DISCOIDEUM_NAME],
  }
  FOUR_WAY_NAME_TO_KINGDOM = {}
  FOUR_WAY_TAXONOMY_DEFINITIONS.each do |kingdom, names|
    names.each do |species_name|
      FOUR_WAY_NAME_TO_KINGDOM[species_name] = kingdom
    end
  end
  
  named_scope :plasmodb, {
    :conditions => "species.name in #{PLASMODB_SPECIES_NAMES.to_sql_in_string}"
  }
  named_scope :toxodb, {
    :conditions => "species.name in #{TOXODB_SPECIES_NAMES.to_sql_in_string}"
  }
  named_scope :cryptodb, {
    :conditions => "species.name in #{CRYPTODB_SPECIES_NAMES.to_sql_in_string}"
  }
  
  # deprecated, because orthomcl now uses four letters for each species
  def update_known_three_letters
    ORTHOMCL_THREE_LETTERS.each do |name, three|
      sp = Species.find_by_name(name)
      raise Exception, "Couldn't find species #{name} to three letter name" if !sp
      sp.orthomcl_three_letter = three
      sp.save!
    end
  end
  
  def update_known_four_letters
    ORTHOMCL_FOUR_LETTERS.each do |name, four|
      sp = Species.find_or_create_by_name(name)
      raise Exception, "Couldn't find species #{name} to three letter name" if !sp
      sp.orthomcl_three_letter = four
      sp.save!
    end
  end
  
  def self.vivax_name
    VIVAX
  end
  
  def self.theileria_parva_name
    THEILERIA_PARVA
  end
  
  def self.theileria_annulata_name
    'Theileria annulata'
  end
  
  def self.falciparum_name
    FALCIPARUM
  end
  
  def self.babesia_bovis_name
    BABESIA_BOVIS_NAME
  end
  
  def self.cryptosporidium_parvum_name
    CRYPTOSPORIDIUM_PARVUM_NAME
  end
  
  def self.cryptosporidium_hominis_name
    CRYPTOSPORIDIUM_HOMINIS_NAME
  end
  
  def self.arabidopsis_name
    'Arabidopsis thaliana'
  end
  
  def self.yeast_name
    'yeast'
  end
  
  def self.elegans_name
    ELEGANS_NAME
  end
  
  def self.mouse_name
    'mouse'
  end
  
  def self.fly_name
    'fly'
  end
  
  def self.pdb_tm_dummy_name
    'pdbtm_dummy'
  end
  
  def self.apicomplexan_names
    APICOMPLEXAN_NAMES
  end
  
  def plasmodb?
    PLASMODB_SPECIES_NAMES.include?(name)
  end
  
  def toxodb?
    TOXODB_SPECIES_NAMES.include?(name)
  end
  
  def cryptodb?
    CRYPTODB_SPECIES_NAMES.include?(name)
  end
  
  def piroplasmadb?
    PIROPLASMADB_SPECIES_NAMES.include?(name)
  end
  
  # Find the species from the gene name, assuming it has a
  # prefix like PfGyrA -> falciparum gene
  #
  # assumes that species prefixes are unique and there is no case where
  # one is the start of another
  def self.find_species_from_prefix(gene_name)
    SPECIES_PREFIXES.each do |key, value|
      if matches = gene_name.match(/^#{value}(.*)/)
        return Species.find_by_name(key)
      end
    end
    return nil #no species prefix found
  end
  
  # Remove the prefix from this species. Assume that it exists
  def remove_species_prefix(gene_name)
    gene_name.match(/^#{SPECIES_PREFIXES[name]}(.*)/)[1]
  end
  
  def number_of_proteins_localised_in_apiloc
    CodingRegion.s(name).count(
      :select => 'distinct(coding_regions.id)',
      :joins => {:expression_contexts => :localisation}
    )
  end
  
  def number_of_publications_in_apiloc
    Publication.count(
      :select => 'distinct(publications.id)',
      :joins => {:expression_contexts => :localisation},
      :conditions => {:localisations => {:species_id => id}}
    )
  end
  
  # Try to return the species with the name as requested
  #  def self.method_missing(method_id)
  #    rets = Species.all(
  #      :conditions => ['name like ?', "%#{method_id.to_s}%"]
  #    )
  #    if rets.length == 1
  #      return rets[0]
  #    else
  #      # well, I tried..
  #      super
  #    end
  #  end
  
  def two_letter_prefix
    # if I've not got the binomial name as the final name, then
    # return nil, otherwise an exception will be raised by
    # LocalisationSpreadsheetRow
    return nil unless name.split(' ').length == 2
    LocalisationSpreadsheetRow.new.generate_prefix_from_binomial_name(name)
  end
  
  def apicomplexan?
    APICOMPLEXAN_NAMES.include?(name)
  end
  
  # By default, sort on the name of the species
  def <=>(another)
    name <=> another.name
  end
  
  def kingdom
    king = NAME_TO_KINGDOM[name]
    unless king
      raise Exception, "No kingdom assigned to species '#{name}', is it entered in the THREE_WAY_TAXONOMY_DEFINITIONS hash?"
    end
    king
  end
  
  def self.four_letter_to_species_name(abbreviation)
    ORTHOMCL_FOUR_LETTERS.each do |name, four|
      return name if abbreviation==four
    end
    raise Exception, "Four letter OrthoMCL letter not recorded: `#{abbreviation}'"
  end
  
  # Is the two letter prefix of a gene such as Tg in TgSPP the same
  # as the species name given. Returns true if yes or there is
  # no matching coding_region_string_id
  def self.agreeable_name_and_two_letter_prefix?(species_name, coding_region_string_id)
    sp = Species.find_species_from_prefix(coding_region_string_id)
    sp2 = Species.find_by_name(species_name)
    if sp.nil? or sp == sp2
      return true
    else
      return false
    end
  end
end
