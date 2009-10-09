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
  
  has_many :scaffolds, :dependent => :destroy
  
  ORTHOMCL_THREE_LETTERS = {
    FALCIPARUM => 'pfa',
    ELEGANS_NAME => 'cel',
    TOXOPLASMA_GONDII_NAME => 'tgo',
    YEAST_NAME=> 'sce',
    MOUSE_NAME=> 'mmu',
    DROSOPHILA_NAME=> 'dme'
  }
  
  def update_known_three_letters
    ORTHOMCL_THREE_LETTERS.each do |name, three|
      sp = Species.find_by_name(name)
      raise Exception, "Couldn't find species #{name} to three letter name" if !sp
      sp.orthomcl_three_letter = three
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
    [
      TOXOPLASMA_GONDII,
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
end
