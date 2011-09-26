require 'localisation_umbrella_mappings'

class ApilocLocalisationTopLevelLocalisation < LocalisationTopLevelLocalisation
  include ApiLocUmbrellaLocalisationMappings
  APILOC_TOP_LEVEL_LOCALISATION_HASH = APILOC_UMBRELLA_LOCALISATION_MAPPINGS
  @@loc_hash = APILOC_TOP_LEVEL_LOCALISATION_HASH
  
  def upload_apiloc_top_level_localisations
    @@loc_hash.each do |top, underlings|
      t = TopLevelLocalisation.find_or_create_by_name(top)
      t_negative = TopLevelLocalisation.find_or_create_by_name("not #{top}")
      underlings.each do |underling|
        # positive
        els = Localisation.find_all_by_name(underling)
        els.each do |l|
          ApilocLocalisationTopLevelLocalisation.find_or_create_by_localisation_id_and_top_level_localisation_id(
                                                                                                                 l.id, t.id
          )
        end
        
        # negative
        els = Localisation.find_all_by_name("not #{underling}")
        els.each do |l|
          ApilocLocalisationTopLevelLocalisation.find_or_create_by_localisation_id_and_top_level_localisation_id(
                                                                                                                 l.id, t_negative.id
          )
        end
      end
    end
    
    # Previously others were added by taking all not in positive, but that is dangerous, especially when adding new localisations
  end
  
  # Check to make sure each loc is assigned a top level localisation
  def check_for_unclassified
    Localisation.positive.all.each do |loc|
      if loc.apiloc_top_level_localisation.nil?
        $stderr.puts "Couldn't find '#{loc.name}' from #{loc.species.name}, #{loc.id} classified in the top level: #{loc.apiloc_top_level_localisation.inspect}"
      end
    end
  end
end
