class Species < ActiveRecord::Base
  FALCIPARUM = 'falciparum'
  VIVAX = 'Plasmodium vivax'
  THEILERIA_PARVA = 'Theileria parva'
  
  has_many :scaffolds, :dependent => :destroy
  
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
end
