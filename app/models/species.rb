class Species < ActiveRecord::Base
  FALCIPARUM = 'falciparum'
  VIVAX = 'Plasmodium vivax'
  THEILERIA_PARVA = 'Theileria parva'
  TOXOPLASMA_GONDII = 'Toxoplasma gondii'
  
  has_many :scaffolds, :dependent => :destroy
  
  ORTHOMCL_THREE_LETTERS = {
    FALCIPARUM => 'pfa'
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
    'Babesia bovis'
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
    'elegans'
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
