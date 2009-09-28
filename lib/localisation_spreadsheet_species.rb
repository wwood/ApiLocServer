# Top level species-specific functions for uploading the localisation
# spreadsheets
module LocalisationSpreadsheetSpecies
  def upload_falciparum(filename='/home/ben/phd/gene lists/falciparum.csv')
    DevelopmentalStage.new.upload_known_falciparum_developmental_stages
    Localisation.new.upload_known_localisations
    Localisation.new.upload_localisation_synonyms
    LocalisationModifier.new.upload_known_modifiers
    upload_localisations_for_species Species::FALCIPARUM_NAME, filename
    TopLevelLocalisation.new.upload_localisations
  end
end
