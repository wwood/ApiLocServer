# Methods associated mainly with uploading data from PlasmoDB and ToxoDB etc.

require 'eu_path_d_b_gene_information_table'
require 'zlib'

class BScript
  PLASMODB_VERSION = '6.1'
  TOXODB_VERSION = '5.2'
  CRYPTODB_VERSION = '4.2'


  def falciparum_to_database
    apidb_species_to_database Species.falciparum_name, "#{DATA_DIR}/falciparum/genome/plasmodb/#{PLASMODB_VERSION}/Pfalciparum_PlasmoDB-#{PLASMODB_VERSION}.gff"
  end

  def berghei_to_database
    apidb_species_to_database Species::BERGHEI_NAME, "#{DATA_DIR}/berghei/genome/plasmodb/#{PLASMODB_VERSION}/Pberghei_PlasmoDB-#{PLASMODB_VERSION}.gff"
  end

  def yoelii_to_database
    apidb_species_to_database Species::YOELII_NAME, "#{DATA_DIR}/yoelii/genome/plasmodb/#{PLASMODB_VERSION}/Pyoelii_PlasmoDB-#{PLASMODB_VERSION}.gff"
  end

  def vivax_to_database
    apidb_species_to_database Species.vivax_name, "#{DATA_DIR}/vivax/genome/plasmodb/#{PLASMODB_VERSION}/Pvivax_PlasmoDB-#{PLASMODB_VERSION}.gff"
  end

  def chabaudi_to_database
    apidb_species_to_database Species.vivax_name, "#{DATA_DIR}/Plasmodium chabaudi/genome/plasmodb/#{PLASMODB_VERSION}/Pchabaudi_PlasmoDB-#{PLASMODB_VERSION}.gff"
  end

  def neospora_caninum_to_database
    apidb_species_to_database Species::NEOSPORA_CANINUM_NAME, "#{DATA_DIR}/Neospora caninum/genome/ToxoDB/#{TOXODB_VERSION}/NeosporaCaninum_ToxoDB-#{TOXODB_VERSION}.gff"
  end

  def cryptosporidium_parvum_to_database
    apidb_species_to_database Species::CRYPTOSPORIDIUM_PARVUM_NAME, "#{DATA_DIR}/Cryptosporidium parvum/genome/cryptoDB/#{CRYPTODB_VERSION}/c_parvum_iowa_ii.gff"
  end

  def gondii_to_database
    apidb_species_to_database Species::TOXOPLASMA_GONDII, "#{DATA_DIR}/Toxoplasma gondii/ToxoDB/#{TOXODB_VERSION}/TgondiiME49_ToxoDB-#{TOXODB_VERSION}.gff"
  end

  def berghei_fasta_to_database
    fa = EuPathDb2009.new('Plasmodium_berghei_str._ANKA','psu').load("#{DATA_DIR}/berghei/genome/plasmodb/#{PLASMODB_VERSION}/PbergheiAnnotatedProteins_PlasmoDB-#{PLASMODB_VERSION}.fasta")
    sp = Species.find_by_name(Species::BERGHEI_NAME)
    upload_fasta_general!(fa, sp)
  end

  def vivax_fasta_to_database
    fa = EuPathDb2009.new('Plasmodium_vivax_SaI-1','gb').load("#{DATA_DIR}/vivax/genome/plasmodb/#{PLASMODB_VERSION}/PvivaxAnnotatedProteins_PlasmoDB-#{PLASMODB_VERSION}.fasta")
    sp = Species.find_by_name(Species::VIVAX_NAME)
    upload_fasta_general!(fa, sp)
  end

  def gondii_fasta_to_database
    fa = EuPathDb2009.new('Toxoplasma_gondii_ME49').load("#{DATA_DIR}/Toxoplasma gondii/ToxoDB/#{TOXODB_VERSION}/TgondiiME49AnnotatedProteins_ToxoDB-#{TOXODB_VERSION}.fasta")
    sp = Species.find_by_name(Species::TOXOPLASMA_GONDII_NAME)
    upload_fasta_general!(fa, sp)
  end

  def gondii_cds_to_database
    fa = EuPathDb2009.new('Toxoplasma_gondii_ME49').load("#{DATA_DIR}/Toxoplasma gondii/ToxoDB/#{TOXODB_VERSION}/TgondiiME49AnnotatedCDS_ToxoDB-#{TOXODB_VERSION}.fasta")
    sp = Species.find_by_name(Species::TOXOPLASMA_GONDII_NAME)
    upload_cds_fasta_general!(fa, sp)
  end

  def upload_gene_information_table(species, gzfile)
    oracle = EuPathDBGeneInformationTable.new(
      Zlib::GzipReader.open(
        gzfile
      ))

    oracle.each do |info|
      # find the gene
      gene_id = info.get_info('ID')
      if info.get_info('Gene') # Toxo is 'ID', whereas falciparum is 'Gene'.
        raise unless gene_id.nil?
        gene_id = info.get_info('Gene')
      end
      code = CodingRegion.fs(gene_id, species.name)
      unless code and code.species.name == species.name
        $stderr.puts "Couldn't find coding region #{gene_id}, skipping"
        next
      end

      associates = info.get_table('GO Terms')
      associates.each do |a|
        go_id = a['GO ID']
        go = GoTerm.find_by_go_identifier_or_alternate(go_id)
        unless go
          $stderr.puts "Couldn't find go term: #{go_id}, skipping"
          next
        end

        CodingRegionGoTerm.find_or_create_by_coding_region_id_and_go_term_id_and_evidence_code(
          code.id,
          go.id,
          a['Evidence Code']
        )
      end
    end
  end


  # Use the gene table to upload the GO terms to the database, including
  # old release 4 identifiers
  def upload_gondii_gene_table_to_database
    upload_gene_information_table(
      Species.find_by_name(Species::TOXOPLASMA_GONDII),
      "#{DATA_DIR}/Toxoplasma gondii/ToxoDB/5.2/TgondiiME49Gene_ToxoDB-5.2.txt.gz"
    ) do |info, code|
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
    end
  end

  def upload_falciparum_gene_table_to_database
    upload_gene_information_table(Species.find_by_name(Species::FALCIPARUM_NAME),
      "#{DATA_DIR}/Plasmodium falciparum/genome/plasmodb/6.1/PfalciparumGene_PlasmoDB-6.1.txt.gz"
    )
  end


  def upload_apiloc_from_scratch
    # Upload basic gene identifiers
    upload_apiloc_gffs
  end

  def upload_apiloc_gffs
    falciparum_to_database
    berghei_to_database
    yoelii_to_database
    vivax_to_database
    chabaudi_to_database
    gondii_to_database
    neospora_caninum_to_database
    cryptosporidium_parvum_to_database
    theileria_parva_gene_aliases
  end
end
