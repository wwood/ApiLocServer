class Localisation < ActiveRecord::Base
  has_many :coding_regions, :through => :coding_region_localisations
  has_many :coding_region_localisations, :dependent => :destroy
  
  # Return a list of ORFs that have this and only this localisation
  def get_individual_localisations
    coding_regions = CodingRegion.find_by_sql(
      "select foo.coding_region_id from (select coding_region_id, count(*) from coding_region_localisations group by coding_region_id having count(*)=1) as foo join coding_region_localisations as food on foo.coding_region_id = food.coding_region_id where food.localisation_id=#{id}"
    )
    return coding_regions
  end
  
  def upload_known_localisations
    [
      'knob', #start of ring, troph, schizont stage locs
      'erythrocyte cytoplasm',
      'maurer\'s clefts',
      'erythrocyte plasma membrane',
      'parasitophorous vacuole',
      'parasitophorous vacuole membrane',
      'parasite plasma membrane',
      'food vacuole',
      'mitochondria',
      'apicoplast',
      'cytosol',
      'cytoplasm',
      'nucleus',
      'golgi',
      'endoplasmic reticulum',
      'vesicles',
      'merozoite surface', #start of merozoite locs
      'inner membrane complex',
      'rhoptry',
      'microneme',
      'mononeme',
      'dense granule',
      'gametocyte surface', #gametocyte locs
      'sporozoite surface', #sporozoite locs
      'ookinete' #mosquito stage locs
    ].each do |loc|
      if !Localisation.find_or_create_by_name(loc)
        raise Exception, "Failed to upload loc '#{loc}' for some reason"
      end
    end
  end
  
  def upload_localisation_synonyms
    {
      'ER' => 'endoplasmic reticulum',
      'tER' => 'endoplasmic reticulum'
    }.each do |key, value|
      loc = Localisation.find_by_name(value)
      if loc
        if !LocalisationSynonym.find_or_create_by_localisation_id_and_name(
            loc.id, 
            key
          )
          raise
        end
      else
        raise Exception, "Could not find localisation #{value}"
      end
    end
  end
  
  # Upload all the data from the localisation list manually collected by ben
  def upload_other_falciparum_list
    CSV.open('/home/ben/phd/gene lists/other/other.csv') do |row|
      
      next if row[0].match(/^\#/) # ignore lines starting with # (comment) characters
      next if row.length < 1 #ignore blank lines
      
      code = CodingRegion.find_by_name_or_alternate_and_organism(row[1], Species.falciparum_name)
      if !code
        raise Exception, "No coding region '#{row[1]}' found."
      end
      
      loc = Localisation.find_by_name
    end
  end
  
  def parse_name
    
  end
end
