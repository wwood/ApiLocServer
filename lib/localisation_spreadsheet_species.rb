require 'reach'
require 'csv'

# Top level species-specific functions for uploading the localisation
# spreadsheets
module LocalisationSpreadsheetSpecies
  def upload_species(species, filename)
    DevelopmentalStage.new.upload_known_developmental_stages species
    Localisation.new.upload_known_localisations species
    Localisation.new.upload_localisation_synonyms species
    LocalisationModifier.new.upload_known_modifiers
    upload_localisations_for_species species, filename
#    TopLevelLocalisation.new.upload_localisations species.name
  end

  def upload_falciparum(filename="#{ENV['HOME']}/phd/gene lists/falciparum.csv")
    upload_species(Species.find_by_name(Species::FALCIPARUM_NAME), filename)
  end

  def upload_toxo(filename="#{ENV['HOME']}/phd/gene lists/toxo.csv")
    upload_manual_toxoplasma_gene_aliases
    upload_species(Species.find_by_name(Species::TOXOPLASMA_GONDII_NAME), filename)
  end

  def upload_babesia_bovis(filename="#{ENV['HOME']}/phd/gene lists/Babesia_bovis.csv")
    upload_species(Species.find_by_name(Species::BABESIA_BOVIS_NAME), filename)
  end

  def upload_neospora_caninum(filename="#{ENV['HOME']}/phd/gene lists/Neospora_caninum.csv")
    upload_species(Species.find_by_name(Species::NEOSPORA_CANINUM_NAME), filename)
  end

  def upload_cryptosporidium_parvum(filename="#{ENV['HOME']}/phd/gene lists/Cryptosporidium_parvum.csv")
    upload_species(Species.find_by_name(Species::CRYPTOSPORIDIUM_PARVUM_NAME), filename)
  end

  def upload_theileria_annulata(filename="#{ENV['HOME']}/phd/gene lists/Theileria_annulata.csv")
    upload_species(Species.find_by_name(Species::THEILERIA_ANNULATA_NAME), filename)
  end

  def upload_theileria_parva(filename="#{ENV['HOME']}/phd/gene lists/Theileria_parva.csv")
    upload_species(Species.find_by_name(Species::THEILERIA_PARVA_NAME), filename)
  end

  def upload_unsequenced_species(filename)
    Species::UNSEQUENCED_APICOMPLEXANS.each do |a|
      Species.find_or_create_by_name(a)
    end
    DevelopmentalStage.new.upload_known_developmental_stages_unsequenced
    Localisation.new.upload_known_localisations_unsequenced
    Localisation.new.upload_localisation_synonyms_unsequenced
    LocalisationModifier.new.upload_known_modifiers
    upload_localisations_for_species nil, filename
#    TopLevelLocalisation.new.upload_localisations_unsequenced
  end

  def upload_sarcocystis_spp(filename="#{ENV['HOME']}/phd/gene lists/Sarcocystis_spp.csv")
    upload_unsequenced_species(filename)
  end

  def upload_babesia_spp(filename="#{ENV['HOME']}/phd/gene lists/Babesia_spp.csv")
    upload_unsequenced_species(filename)
  end

  def upload_theileria_spp(filename="#{ENV['HOME']}/phd/gene lists/Theileria_spp.csv")
    upload_unsequenced_species(filename)
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
