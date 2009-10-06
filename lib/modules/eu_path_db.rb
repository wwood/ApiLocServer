# Methods associated mainly with uploading data from PlasmoDB and ToxoDB etc.

require 'eu_path_d_b_gene_information_table'
require 'zlib'

class BScript

  def falciparum_to_database
    # abstraction!
    #    apidb_species_to_database Species.falciparum_name, "#{DATA_DIR}/falciparum/genome/plasmodb/5.4/Pfalciparum_3D7_plasmoDB-5.4.gff"
    #    apidb_species_to_database Species.falciparum_name, "#{DATA_DIR}/falciparum/genome/plasmodb/5.5/Pfalciparum_PlasmoDB-5.5.gff"
    apidb_species_to_database Species.falciparum_name, "#{DATA_DIR}/falciparum/genome/plasmodb/6.0/Pfalciparum_PlasmoDB-6.0.gff"
  end

  def berghei_to_database
    # abstraction!
    #    apidb_species_to_database Species.falciparum_name, "#{DATA_DIR}/falciparum/genome/plasmodb/5.4/Pfalciparum_3D7_plasmoDB-5.4.gff"
    #    apidb_species_to_database Species.falciparum_name, "#{DATA_DIR}/falciparum/genome/plasmodb/5.5/Pfalciparum_PlasmoDB-5.5.gff"
    apidb_species_to_database Species::BERGHEI_NAME, "#{DATA_DIR}/berghei/genome/plasmodb/6.0/Pberghei_PlasmoDB-6.0.gff"
  end

  def berghei_fasta_to_database
    fa = EuPathDb2009.new('Plasmodium_berghei_str._ANKA','psu').load("#{DATA_DIR}/berghei/genome/plasmodb/6.0/PbergheiAnnotatedProteins_PlasmoDB-6.0.fasta")
    sp = Species.find_by_name(Species::BERGHEI_NAME)
    upload_fasta_general!(fa, sp)
  end

  def vivax_fasta_to_database
    fa = EuPathDb2009.new('Plasmodium_vivax_SaI-1','gb').load("#{DATA_DIR}/vivax/genome/plasmodb/6.0/PvivaxAnnotatedProteins_PlasmoDB-6.0.fasta")
    sp = Species.find_by_name(Species::VIVAX_NAME)
    upload_fasta_general!(fa, sp)
  end

  def gondii_to_database
    #    apidb_species_to_database Species::TOXOPLASMA_GONDII, "#{DATA_DIR}/Toxoplasma gondii/ToxoDB/4.3/TgondiiME49/ToxoplasmaGondii_ME49_ToxoDB-4.3.gff"
    #    apidb_species_to_database Species::TOXOPLASMA_GONDII, "#{DATA_DIR}/Toxoplasma gondii/ToxoDB/5.0/TgondiiME49_ToxoDB-5.0.gff"
    apidb_species_to_database Species::TOXOPLASMA_GONDII, "#{DATA_DIR}/Toxoplasma gondii/ToxoDB/5.2/TgondiiME49_ToxoDB-5.2.gff"
  end

  def gondii_fasta_to_database
    #    fa = ToxoDbFasta4p3.new.load("#{DATA_DIR}/Toxoplasma gondii/ToxoDB/4.3/TgondiiME49/TgondiiAnnotatedProteins_toxoDB-4.3.fasta")
    #    fa = EuPathDb2009.new('Toxoplasma_gondii_ME49').load("#{DATA_DIR}/Toxoplasma gondii/ToxoDB/5.0/TgondiiME49AnnotatedProteins_ToxoDB-5.0.fasta")
    fa = EuPathDb2009.new('Toxoplasma_gondii_ME49').load("#{DATA_DIR}/Toxoplasma gondii/ToxoDB/5.2/TgondiiME49AnnotatedProteins_ToxoDB-5.2.fasta")
    sp = Species.find_by_name(Species::TOXOPLASMA_GONDII_NAME)
    upload_fasta_general!(fa, sp)
  end

  def gondii_cds_to_database
    fa = EuPathDb2009.new('Toxoplasma_gondii_ME49').load("#{DATA_DIR}/Toxoplasma gondii/ToxoDB/5.2/TgondiiME49AnnotatedCDS_ToxoDB-5.2.fasta")
    sp = Species.find_by_name(Species::TOXOPLASMA_GONDII_NAME)
    upload_cds_fasta_general!(fa, sp)
  end


  # Use the gene table to upload the GO terms to the database
  def upload_gondii_gene_table_to_database
    oracle = EuPathDBGeneInformationTable.new(
      Zlib::GzipReader.open(
        "#{DATA_DIR}/Toxoplasma gondii/ToxoDB/5.2/TgondiiME49Gene_ToxoDB-5.2.txt.gz"
      ))

    oracle.each do |info|
      # find the gene
      gene_id = info.get_info('ID')
      code = CodingRegion.fs(gene_id, Species::TOXOPLASMA_GONDII_NAME)
      unless code and code.species.name == Species::TOXOPLASMA_GONDII_NAME
        $stderr.puts "Couldn't find coding region #{gene_id}, skipping"
        next
      end

      release_fours = info.get_info('Release4 IDs')
      r4 = release_fours.split(/\s/).reject{|s|s.nil? or s==''}
      if r4 == ['null']
      else
        r4.each do |four|
          CodingRegionAlternateStringId.find_or_create_by_coding_region_id_and_name(
            code.id,
            four
          ) or raise
        end
      end

#      associates = info.get_table('GO Terms')
#      associates.each do |a|
#        go_id = a['GO ID']
#        go = GoTerm.find_by_go_identifier_or_alternate(go_id)
#        unless go
#          $stderr.puts "Couldn't find go term: #{go_id}, skipping"
#          next
#        end
#
#        CodingRegionGoTerm.find_or_create_by_coding_region_id_and_go_term_id_and_evidence_code(
#          code.id,
#          go.id,
#          a['Evidence Code']
#        )
#      end
    end
  end
end
