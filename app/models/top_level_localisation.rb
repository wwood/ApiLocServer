class TopLevelLocalisation < ActiveRecord::Base
  has_many :malaria_localisation_top_level_localisations
  has_many :malaria_localisations, :through => :malaria_localisation_top_level_localisations
  
  # A hash of all non-top levels locs to top level ones
  LOC_HASH = {
    'knob' => 'exported',
    'erythrocyte cytoplasm' => 'exported',
    'maurer\'s clefts' => 'exported',
    'erythrocyte plasma membrane' => 'exported',
    'parasitophorous vacuole membrane' => 'parasitophorous vacuole',
    'parasite plasma membrane' => 'cytosol',
    'food vacuole membrane' => 'food vacuole',
    'mitochondrial membrane' => 'mitochondria',
    'cytoplasm' => 'cytosol',
    'vesicles' => 'cytosol',
    'rhoptry' => 'apical',
    'microneme' => 'apical',
    'mononeme' => 'apical',
    'dense granule' => 'apical',
    'gametocyte nucleus' => 'nucleus',
    'gametocyte cytoplasm' => 'cytosol',
    'gametocyte parasitophorous vacuole' => 'parasitophorous vacuole',
    'sporozoite cytoplasm' => 'cytosol',
    'ookinete microneme' => 'apical',
    'hepatocyte cytoplasm' => 'cytosol',
    'hepatocyte nucleus' => 'nucleus',
    'hepatocyte parasitophorous vacuole membrane' => 'parasitophorous vacuole'
  }
  
  TOP_LEVEL_LOCALISATIONS = [
    'exported',
    'mitochondria',
    'food vacuole',
    'parasitophorous vacuole',
    'apicoplast',
    'cytosol',
    'nucleus',
    'golgi',
    'endoplasmic reticulum',
    'merozoite surface',
    'inner membrane complex',
    'gametocyte surface',
    'sporozoite surface',
    'apical'
  ]
  
  def upload_localisations
    # upload all the normal ones
    TOP_LEVEL_LOCALISATIONS.each do |top|
      t = TopLevelLocalisation.find_or_create_by_name(top)
      if top != 'exported'
        l = Localisation.find_by_name(top) or raise
        MalariaLocalisationTopLevelLocalisation.find_or_create_by_localisation_id_and_top_level_localisation_id(
          t.id,
          l.id
        ) or raise
      end
    end
    
    # upload all the other ones
    LOC_HASH.each do |loc, top|
      t = TopLevelLocalisation.find_by_name(top) or raise Exception, "Couldn't find top #{top}"
      l = Localisation.find_by_name(loc) or raise
      MalariaLocalisationTopLevelLocalisation.find_or_create_by_localisation_id_and_top_level_localisation_id(
        t.id,
        l.id
      ) or raise
    end
  end
end
