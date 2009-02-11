class Species < ActiveRecord::Base
  FALCIPARUM = 'falciparum'
  FALCIPARUM_NAME = FALCIPARUM
  VIVAX = 'Plasmodium vivax'
  VIVAX_NAME = VIVAX
  THEILERIA_PARVA = 'Theileria parva'
  TOXOPLASMA_GONDII = 'Toxoplasma gondii'
  TOXOPLASMA_GONDII_NAME = TOXOPLASMA_GONDII
  ELEGANS_NAME = 'elegans'
  BABESIA_BOVIS_NAME = 'Babesia bovis'
  YEAST_NAME= 'yeast'
  MOUSE_NAME = 'mouse'
  DROSOPHILA_NAME= 'fly'
  
  has_many :scaffolds, :dependent => :destroy
  
  ORTHOMCL_THREE_LETTERS = {
    FALCIPARUM => 'pfa',
    ELEGANS_NAME => 'cel',
    #TOXOPLASMA_GONDII_NAME => 'tgo',
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
    'Cryptosporidium parvum'
  end
  
  def self.cryptosporidium_hominis_name
    'Cryptosporidium hominis'
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
      VIVAX
    ]
  end
end
