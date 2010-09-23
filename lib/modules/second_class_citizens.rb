require 'second_class_localisation_spreadsheet'

# Methods to do with second class citizens (silver localisation data set) 
class BScript
  def second_class_citizens_to_database(csv_filename="#{PHD_DIR}/gene lists/second class citizens.csv")
    # setup database
    Localisation::KNOWN_LOCALISATIONS.keys.each do |species_name|
      species = Species.find_by_name(species_name)
      if species.nil?
        $stderr.puts "Not uploading localisation and dev stage constants for '#{species_name}', since there is no known species of that name."
      else
        DevelopmentalStage.new.upload_known_developmental_stages species
        Localisation.new.upload_known_localisations species
        Localisation.new.upload_localisation_synonyms species
        LocalisationModifier.new.upload_known_modifiers
      end  
    end
    
    LocalisationSpreadsheet.new.upload_manual_toxoplasma_gene_aliases
    
    # Do the actual upload
    SecondClassLocalisationSpreadsheet.new.upload(csv_filename)
  end
end