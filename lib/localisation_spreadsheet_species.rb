require 'reach'
require 'csv'

# Top level species-specific functions for uploading the localisation
# spreadsheets
module LocalisationSpreadsheetSpecies
  def restart
    LocalisationAnnotation.destroy_all
    ExpressionContext.destroy_all
    Localisation.destroy_all
    LocalisationSynonym.destroy_all
    DevelopmentalStage.destroy_all
    DevelopmentalStageSynonym.destroy_all
  end
  
  def upload
    $stderr.puts '------ Uploading Plasmodium falciparum------'
    upload_falciparum
    $stderr.puts '------ Uploading Plasmodium knowlesi------'
    upload_knowlesi
    $stderr.puts '------ Uploading Plasmodium yoelii------'
    upload_yoelii
    $stderr.puts '------ Uploading Plasmodium berghei------'
    upload_berghei
    $stderr.puts '------ Uploading Plasmodium vivax------'
    upload_vivax
    $stderr.puts '------ Uploading Plasmodium chabaudi------'
    upload_chabaudi
    
    $stderr.puts '------ Uploading Toxoplasma gondii------'
    upload_toxo
    $stderr.puts '------ Uploading Babesia bovis------'
    upload_babesia_bovis
    $stderr.puts '------ Uploading Neospora caninum------'
    upload_neospora_caninum
    $stderr.puts '------ Uploading Eimeria tenella------'
    upload_eimeria_tenella
    $stderr.puts '------ Uploading Cryptosporidium parvum------'
    upload_cryptosporidium_parvum
    $stderr.puts '------ Uploading Theileria annulata------'
    upload_theileria_annulata
    $stderr.puts '------ Uploading Theileria parva------'
    upload_theileria_parva
    
    $stderr.puts '------ Uploading unsequenced sarcocystis_spp------'
    upload_sarcocystis_spp
    $stderr.puts '------ Uploading unsequenced babesia_spp------'
    upload_babesia_spp
    $stderr.puts '------ Uploading unsequenced theileria_spp------'
    upload_theileria_spp
    $stderr.puts '------ Uploading unsequenced plasmodium_spp------'
    upload_plasmodium_spp
    $stderr.puts '------ Uploading unsequenced eimeria_spp------'
    upload_eimeria_spp
    
    $stderr.puts '------ High level locs and dev stages------'
    DevelopmentalStageTopLevelDevelopmentalStage.new.upload_apiloc_top_level_developmental_stages
    ApilocLocalisationTopLevelLocalisation.new.upload_apiloc_top_level_localisations
    
    Publication.fill_in_all_extras!
    gather_genbank_sequences_and_names
  end
  
  def upload_species(species, filename)
    # upload locs & dev stages
    upload_static_info(species)
    #
    upload_localisations_for_species species, filename
    #    TopLevelLocalisation.new.upload_localisations species.name
  end
  
  # Upload the info that is static in the db code (localisations, dev stages)
  # except top level encodings, which are done in a separate method
  def upload_static_info(species)
    DevelopmentalStage.new.upload_known_developmental_stages species
    Localisation.new.upload_known_localisations species
    Localisation.new.upload_localisation_synonyms species
    LocalisationModifier.new.upload_known_modifiers
  end
  
  def upload_falciparum(filename="#{ENV['HOME']}/phd/gene lists/falciparum.csv")
    upload_species(Species.find_by_name(Species::FALCIPARUM_NAME), filename)
  end
  
  def upload_berghei(filename="#{ENV['HOME']}/phd/gene lists/berghei.csv")
    upload_species(Species.find_by_name(Species::BERGHEI_NAME), filename)
  end
  
  def upload_vivax(filename="#{ENV['HOME']}/phd/gene lists/vivax.csv")
    upload_species(Species.find_by_name(Species::VIVAX_NAME), filename)
  end
  
  def upload_yoelii(filename="#{ENV['HOME']}/phd/gene lists/yoelii.csv")
    upload_species(Species.find_by_name(Species::YOELII_NAME), filename)
  end
  
  def upload_knowlesi(filename="#{ENV['HOME']}/phd/gene lists/knowlesi.csv")
    upload_species(Species.find_by_name(Species::KNOWLESI_NAME), filename)
  end
  
  def upload_chabaudi(filename="#{ENV['HOME']}/phd/gene lists/chabaudi.csv")
    upload_species(Species.find_by_name(Species::CHABAUDI_NAME), filename)
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
    
  def upload_eimeria_tenella(filename="#{ENV['HOME']}/phd/gene lists/Eimeria_tenella.csv")
    upload_species(Species.find_by_name(Species::EIMERIA_TENELLA_NAME), filename)
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
  
  def upload_plasmodium_spp(filename="#{ENV['HOME']}/phd/gene lists/Plasmodium_spp.csv")
    upload_unsequenced_species(filename)
  end
  
  def upload_babesia_spp(filename="#{ENV['HOME']}/phd/gene lists/Babesia_spp.csv")
    upload_unsequenced_species(filename)
  end
  
  def upload_theileria_spp(filename="#{ENV['HOME']}/phd/gene lists/Theileria_spp.csv")
    upload_unsequenced_species(filename)
  end
  
  def upload_eimeria_spp(filename="#{ENV['HOME']}/phd/gene lists/Eimeria_spp.csv")
    upload_unsequenced_species(filename)
  end
  
  
  
  # Mapping some genes to modern IDs is problematic and annoying. Blargh.
  # So uploaded a bunch manually to ToxoDB, and am now parsing the
  # results of that and other genes manually.
  def upload_manual_toxoplasma_gene_aliases
    manual_name_files = [
    "#{ENV['HOME']}/phd/data/Toxoplasma gondii/ToxoDB/5.2/selectedRelease4Release5.2map.csv",
    "#{ENV['HOME']}/phd/data/Toxoplasma gondii/ToxoDB/6.0/selectedRelease4Release6.0map.csv"
    ]
    
    manual_name_files.each do |filename|
      CSV.open(filename, 'r', "\t").each do |row|
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
  
  # For all unsequenced genomes, retrieve their amino acid sequences
  # so that a fasta file of localised amino acid sequences can be gotten,
  # and annotation is available
  def gather_genbank_sequences_and_names
    Species::UNSEQUENCED_APICOMPLEXANS.each do |sp|
      CodingRegion.s(sp).all.each do |code|
        
        if code.aaseq
          puts "Skipping #{code.string_id}"
        else
          raise unless code.annotation.nil? #No idea why this would be the case, but uno..
          translateds = GenBankToGeneModelMapper.new.get_translated_sequences_from_genbank(code.string_id)
          if translateds.length == 1
            # All good
            trans = translateds[0]
            puts "Uploading #{code.string_id} #{trans.seq.length} #{trans.definition}"
            AminoAcidSequence.find_or_create_by_coding_region_id_and_sequence(code.id, trans.seq)
            Annotation.find_or_create_by_coding_region_id_and_annotation(code.id, trans.definition)
          else
            # damn genbank
            $stderr.puts "Unexpected number of genbanks found for #{code.string_id}: #{translateds.length}: #{translateds.inspect}"
          end
        end
      end
    end
  end
  
  def create_apiloc_blast_database
    # open a file called apiloc_new.fa, then move that to apiloc.fa
    # so that nothing strange happens when blasting the database at the
    # same time as uploading to it.
    File.open('/tmp/apiloc.protein.fa','w') do |file|
      BScript.new.apiloc_fasta(file)
    end
    
    # create the blast databases
    Dir.chdir('/tmp') do
      `formatdb -i apiloc.protein.fa`
      
      %w(
        apiloc.protein.fa
        apiloc.protein.fa.phr
        apiloc.protein.fa.pin
        apiloc.protein.fa.psq
      ).each do |filename|
        `mv #{filename} /var/www/blast/db`
      end
    end
  end
end
