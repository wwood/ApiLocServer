require 'reach'

# Top level species-specific functions for uploading the localisation
# spreadsheets
module LocalisationSpreadsheetSpecies
  def upload_falciparum(filename="#{ENV['HOME']}/phd/gene lists/falciparum.csv")
    sp = Species.find_by_name(Species::FALCIPARUM_NAME)
    DevelopmentalStage.new.upload_known_developmental_stages sp
    Localisation.new.upload_known_localisations sp
    Localisation.new.upload_localisation_synonyms sp
    LocalisationModifier.new.upload_known_modifiers
    upload_localisations_for_species sp, filename
    TopLevelLocalisation.new.upload_localisations sp.name
  end

  def upload_toxo(filename="#{ENV['HOME']}/phd/gene lists/toxo.csv")
    sp = Species.find_by_name(Species::TOXOPLASMA_GONDII_NAME)
    DevelopmentalStage.new.upload_known_developmental_stages sp
    Localisation.new.upload_known_localisations sp
    Localisation.new.upload_localisation_synonyms sp
    LocalisationModifier.new.upload_known_modifiers
    upload_manual_toxoplasma_gene_aliases
    upload_localisations_for_species sp, filename
    TopLevelLocalisation.new.upload_localisations sp.name
  end

  # Mapping some genes to modern IDs is problematic and annoying. Blargh.
  # So uploaded a bunch manually to ToxoDB, and am now parsing the
  # results of that and other genes manually.
  def upload_manual_toxoplasma_gene_aliases
    CSV.open("#{ENV['HOME']}/phd/data/Toxoplasma gondii/ToxoDB/5.2/selectedRelease4Release5.2map.csv", 'r', "\t").each do |row|
      next unless row.length == 2 or row.length == 3
      modern = row[0].strip
      olds = row[1].split(',').reach.strip
      next if olds[0] == 'null'
      code = CodingRegion.find_by_name_or_alternate_and_organism(modern, Species::TOXOPLASMA_GONDII_NAME)
      raise Exception, "No coding region #{modern} like you said there would be. You Liar!" unless code
      olds.each do |old|
        CodingRegionAlternateStringId.find_or_create_by_name_and_coding_region_id(
          old, code.id
        )
      end
    end
  end
end
