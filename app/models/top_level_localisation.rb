class TopLevelLocalisation < ActiveRecord::Base
  has_many :malaria_localisation_top_level_localisations
  has_many :malaria_localisations, 
    :through => :malaria_localisation_top_level_localisations,
    :source => :localisation

  has_many :apiloc_localisation_top_level_localisations
  has_many :apiloc_localisations,
    :through => :apiloc_localisation_top_level_localisations,
    :source => :localisation

  has_many :curated_top_level_localisations
  
  named_scope :known, lambda { { :conditions => ['name in (?)', TOP_LEVEL_LOCALISATIONS] } }
  named_scope :positive, {
    :conditions => ['top_level_localisations.name not like ?', 'not %']
  }
  named_scope :negative, {
    :conditions => ['top_level_localisations.name like ?', 'not %']
  }

  # A hash of all non-top levels locs to top level ones
  LOC_HASH = {
    'knob' => 'exported',
    'erythrocyte cytoplasm' => 'exported',
    'maurer\'s clefts' => 'exported',
    'erythrocyte plasma membrane' => 'exported',
    'parasitophorous vacuole membrane' => 'parasitophorous vacuole membrane', #there is 9 of these!
    'parasite plasma membrane' => 'parasite plasma membrane',
    #    'food vacuole membrane' => 'food vacuole',
    #    'mitochondrial membrane' => 'mitochondria',
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
    'hepatocyte parasitophorous vacuole membrane' => 'parasitophorous vacuole',
    'diffuse cytoplasm' => 'cytosol'
  }
  
  TOP_LEVEL_LOCALISATIONS = [
    'parasitophorous vacuole membrane',
    'parasite plasma membrane',
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
    #    'sporozoite surface',
    'apical'
  ]

  TOXOPLASMA_GONDII_LOCALISATIONS = [

  ]
  
  def upload_localisations
    # upload all the normal ones
    TOP_LEVEL_LOCALISATIONS.each do |top|
      t = TopLevelLocalisation.find_or_create_by_name(top)
      if top != 'exported'
        l = Localisation.find_by_name(top) or raise
        MalariaLocalisationTopLevelLocalisation.find_or_create_by_localisation_id_and_top_level_localisation_id(
          l.id,
          t.id
        ) or raise
      end
    end
    
    # upload all the other ones
    LOC_HASH.each do |loc, top|
      t = TopLevelLocalisation.find_by_name(top) or raise Exception, "Couldn't find top #{top}"
      l = Localisation.find_by_name(loc) or raise
      MalariaLocalisationTopLevelLocalisation.find_or_create_by_localisation_id_and_top_level_localisation_id(
        l.id,
        t.id
      ) or raise
    end
  end

  def negation
    if matches = name.match(/^not (.*)/)
      t = TopLevelLocalisation.find_by_name(matches[1])
      raise if t.nil?
      return t
    else
      t = TopLevelLocalisation.find_by_name("not #{name}")
      raise if t.nil?
      return t
    end
  end

  def negative?
    name.match(/^not /)
  end
end
