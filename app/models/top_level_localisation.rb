class TopLevelLocalisation < ActiveRecord::Base
  has_many :localisations
  
  # A hash of all non-top levels locs to top level ones
  LOC_HASH = {
    'knob' => 'exported',
    'erythrocyte cytoplasm' => 'exported',
    'maurer\'s clefts' => 'exported',
    'erythrocyte plasma membrane' => 'exported',
    'parasitophorous vacuole membrane' => 'parasitophorous vacuole',
    'parasite plasma membrane' => 'parasite plasma membrane',
    'food vacuole membrane' => 'food vacuole',
    'mitochondrial membrane' => 'mitochondria',
    'cytoplasm' => 'cytosol',
    'vesicles' => 'cytosol',
    'rhoptry' => 'apical',
    'microneme' => 'apical',
    'mononeme' => 'apical',
    'dense granule' => 'apical',
    'gametocyte nucleus' => 'nucleus',
    'gametocyte cytoplasm' => 'cytoplasm',
    'gametocyte parasitophorous vacuole' => 'parasitophorous vacuole',
    'sporozoite cytoplasm' => 'cytoplasm',
    'ookinete microneme' => 'apical',
    'hepatocyte cytoplasm' => 'cytoplasm',
    'hepatocyte nucleus' => 'nucleus',
    'hepatocyte parasitophorous vacuole membrane' => 'parasitophorous vacuole'
  }
  
  TOP_LEVEL_LOCALISATIONS = [
    'mitochondria',
    'food vacuole',
    'parasitophorous vacuole',    
    'mitochondria',
    'apicoplast',
    'cytosol',
    'nucleus',
    'golgi',
    'endoplasmic reticulum',
    'merozoite surface',
    'inner membrane complex',
    'gametocyte surface',
    'sporozoite surface'
  ]
  
  def upload_localisations
    # upload all the normal ones
    TOP_LEVEL_LOCALISATIONS.each do |top|
      TopLevelLocalisation.find_or_create_by_name(top) or raise
    end
    
    # upload all the other ones
    LOC_HASH.each do |loc, top|
      t = TopLevelLocalisation.find_by_name(top) or raise
      l = Localisation.find_by_name(loc) or raise
      l.top_level_localisation_id = t.id
      l.save!
    end
  end
end
