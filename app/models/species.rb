class Species < ActiveRecord::Base
  FALCIPARUM = 'falciparum'
  FALCIPARUM_NAME = FALCIPARUM
  VIVAX = 'Plasmodium vivax'
  VIVAX_NAME = VIVAX
  BERGHEI_NAME = 'Plasmodium berghei'
  YOELII_NAME = 'Plasmodium yoelii'
  CHABAUDI_NAME = 'Plasmodium chabaudi'
  KNOWLESI_NAME = 'Plasmodium knowlesi'
  THEILERIA_PARVA = 'Theileria parva'
  THEILERIA_PARVA_NAME = THEILERIA_PARVA
  THEILERIA_ANNULATA_NAME = 'Theileria annulata'
  TOXOPLASMA_GONDII = 'Toxoplasma gondii'
  TOXOPLASMA_GONDII_NAME = TOXOPLASMA_GONDII
  NEOSPORA_CANINUM_NAME = 'Neospora caninum'
  ELEGANS_NAME = 'elegans'
  BABESIA_BOVIS_NAME = 'Babesia bovis'
  YEAST_NAME= 'yeast'
  MOUSE_NAME = 'mouse'
  DROSOPHILA_NAME= 'fly'
  CYRYPTOSPORIDIUM_HOMINIS_NAME = 'Cryptosporidium hominis'
  CYRYPTOSPORIDIUM_PARVUM_NAME = 'Cryptosporidium parvum'
  CYRYPTOSPORIDIUM_MURIS_NAME = 'Cryptosporidium muris'

  # Not ever uploaded as a species, just a useful constant
  OTHER_SPECIES = 'Other species placeholder'

  UNSEQUENCED_APICOMPLEXANS = [
    'Plasmodium gallinaceum',
    'Sarcocystus neurona',
    'Sarcocystus muris',
  ]

  APICOMPLEXAN_NAMES = [
    TOXOPLASMA_GONDII,
    NEOSPORA_CANINUM_NAME,
    FALCIPARUM,
    VIVAX,
    BERGHEI_NAME,
    YOELII_NAME,
    BABESIA_BOVIS_NAME,
    CYRYPTOSPORIDIUM_HOMINIS_NAME,
    CYRYPTOSPORIDIUM_PARVUM_NAME,
    THEILERIA_PARVA_NAME,
    THEILERIA_ANNULATA_NAME,
  ]
  
  has_many :scaffolds, :dependent => :destroy

  named_scope :apicomplexan, {
    :conditions => "species.name in #{Species::APICOMPLEXAN_NAMES.to_sql_in_string}"
  }
  
  ORTHOMCL_THREE_LETTERS = {
    FALCIPARUM => 'pfa',
    ELEGANS_NAME => 'cel',
    TOXOPLASMA_GONDII_NAME => 'tgo',
    YEAST_NAME=> 'sce',
    MOUSE_NAME=> 'mmu',
    DROSOPHILA_NAME=> 'dme'
  }

  ORTHOMCL_FOUR_LETTERS = {
    FALCIPARUM => 'pfal',
    VIVAX_NAME => 'pviv',
    BERGHEI_NAME => 'pber',
    YOELII_NAME => 'pyoe',
    KNOWLESI_NAME => 'pkno',
    CYRYPTOSPORIDIUM_HOMINIS_NAME => 'chom',
    CYRYPTOSPORIDIUM_PARVUM_NAME => 'cpar',
    CYRYPTOSPORIDIUM_MURIS_NAME => 'cmur',
    THEILERIA_PARVA_NAME => 'tpar',
    THEILERIA_ANNULATA_NAME => 'tann',
    ELEGANS_NAME => 'cele',
    TOXOPLASMA_GONDII_NAME => 'tgon',
    NEOSPORA_CANINUM_NAME => 'ncan',
    YEAST_NAME => 'scer',
    MOUSE_NAME => 'mmus',
    DROSOPHILA_NAME => 'dmel',
    NEOSPORA_CANINUM_NAME => 'ncan'
  }

  SPECIES_PREFIXES = {
    FALCIPARUM_NAME => 'Pf',
    TOXOPLASMA_GONDII_NAME => 'Tg',
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
    CYRYPTOSPORIDIUM_PARVUM_NAME
  end
  
  def self.cryptosporidium_hominis_name
    CYRYPTOSPORIDIUM_HOMINIS_NAME
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
    [
      FALCIPARUM,
      VIVAX,
      BERGHEI_NAME,
      YOELII_NAME,
      CHABAUDI_NAME,
      KNOWLESI_NAME,
    ].include?(name)
  end

  def toxodb?
    [
      TOXOPLASMA_GONDII_NAME,
      NEOSPORA_CANINUM_NAME
    ].include?(name)
  end

  def cryptodb?
    [
      CYRYPTOSPORIDIUM_HOMINIS_NAME,
      CYRYPTOSPORIDIUM_PARVUM_NAME,
      CYRYPTOSPORIDIUM_MURIS_NAME
    ].include?(name)
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
end
