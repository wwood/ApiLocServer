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
    apidb_species_to_database Species::CHABAUDI_NAME, "#{DATA_DIR}/Plasmodium chabaudi/genome/plasmodb/#{PLASMODB_VERSION}/Pchabaudi_PlasmoDB-#{PLASMODB_VERSION}.gff"
  end

  def knowlesi_to_database
    apidb_species_to_database Species::KNOWLESI_NAME, "#{DATA_DIR}/knowlesi/genome/plasmodb/#{PLASMODB_VERSION}/Pknowlesi_PlasmoDB-#{PLASMODB_VERSION}.gff"
  end

  def neospora_caninum_to_database
    apidb_species_to_database Species::NEOSPORA_CANINUM_NAME, "#{DATA_DIR}/Neospora caninum/genome/ToxoDB/#{TOXODB_VERSION}/NeosporaCaninum_ToxoDB-#{TOXODB_VERSION}.gff"
  end

  def cryptosporidium_parvum_to_database
    apidb_species_to_database Species::CRYPTOSPORIDIUM_PARVUM_NAME, "#{DATA_DIR}/Cryptosporidium parvum/genome/cryptoDB/#{CRYPTODB_VERSION}/c_parvum_iowa_ii.gff"
  end

  def cryptosporidium_hominis_to_database
    apidb_species_to_database Species::CRYPTOSPORIDIUM_HOMINIS_NAME, "#{DATA_DIR}/Cryptosporidium hominis/genome/cryptoDB/#{CRYPTODB_VERSION}/c_hominis_tu502.gff"
  end

  def cryptosporidium_muris_to_database
    apidb_species_to_database Species::CRYPTOSPORIDIUM_MURIS_NAME, "#{DATA_DIR}/Cryptosporidium muris/genome/cryptodb/#{CRYPTODB_VERSION}/c_muris.gff"
  end

  def gondii_to_database
    apidb_species_to_database Species::TOXOPLASMA_GONDII, "#{DATA_DIR}/Toxoplasma gondii/ToxoDB/#{TOXODB_VERSION}/TgondiiME49_ToxoDB-#{TOXODB_VERSION}.gff"
  end

  def theileria_parva_genbank_gff_to_database
    [
      'NC_007344.gff',
      'NC_007345.gff',
      'NC_007758.gff'
    ].each do |gff_file|
      gff_file_path = "#{DATA_DIR}/Theileria parva/genome/ncbi/#{gff_file}"
      GFF3ParserLight.new(File.open(gff_file_path)).each_feature('CDS') do |feature|
        locus_tag = feature.attributes['locus_tag']
        code = CodingRegion.fs(locus_tag, Species::THEILERIA_PARVA_NAME)
        unless code
          $stderr.puts "Couldn't find coding region #{locus_tag}"
          next
        end

        protein_id = feature.attributes['protein_id']
        if matches = protein_id.match(/(.*)\.[123456789]$/)
          pro = matches[1]
          $stderr.puts "adding #{pro} for #{code.string_id}"
          CodingRegionAlternateStringId.find_or_create_by_name_and_coding_region_id(
            pro, code.id
          ) or raise
        else
          raise Exception, "couldn't parse #{protein_id} (take the .1 or whatever off the end)"
        end
      end
    end
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

  # low level method. don't create coding regions or GO terms, just
  # parse the file
  def upload_gene_information_table_plumbing(gzfile)
    oracle = EuPathDBGeneInformationTable.new(
      Zlib::GzipReader.open(
        gzfile
      ))

    oracle.each do |info|
      yield info #have to give a block, otherwise why are you calling me?
    end
  end

  # High level for general EuPathDB use. Find coding regions and upload
  # GO terms associated and give a yield for further uploads on a gene
  # entry basis.
  def upload_gene_information_table(species, gzfile)
    upload_gene_information_table_plumbing(gzfile) do |info|
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

      yield info, code if block_given?
    end
  end


  # Use the gene table to upload the GO terms to the database, including
  # old release 4 identifiers
  def upload_gondii_gene_table_to_database
    upload_gene_information_table(
      Species.find_by_name(Species::TOXOPLASMA_GONDII),
      "#{DATA_DIR}/Toxoplasma gondii/ToxoDB/#{TOXODB_VERSION}/TgondiiME49Gene_ToxoDB-#{TOXODB_VERSION}.txt.gz"
    ) do |info, code|
      # Add release 4 IDs as direct aliases
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

      # Add strain orthologue information from non ME49 strains,
      # (initially at least this was done so that OrthoMCL v3 could be
      # uploaded properly.
      strains_table = info.get_table('Strains summary')
      strains_table.each do |row|
        name = row['Gene']
        unless name == code.string_id
          CodingRegionStrainOrthologue.find_or_create_by_name_and_coding_region_id(
            name, code.id
          ) or raise
        end
      end

      # Add within-ToxoDB Orthologue info as well
      
    end
  end

  def upload_falciparum_gene_table_to_database
    upload_gene_information_table(Species.find_by_name(Species::FALCIPARUM_NAME),
      "#{DATA_DIR}/Plasmodium falciparum/genome/plasmodb/#{PLASMODB_VERSION}/PfalciparumGene_PlasmoDB-#{PLASMODB_VERSION}.txt.gz"
    )
  end


  def upload_apiloc_from_scratch
    # Upload basic gene identifiers
    upload_apiloc_gffs
    upload_gondii_gene_table_to_database
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
    upload_theileria_fasta
    babesia_to_database
  end

  # upload the fasta sequences from falciparum file to the database
  def falciparum_fasta_to_database
    fa = ApiDbFasta5p5.new.load("#{DATA_DIR}/falciparum/genome/plasmodb/#{PLASMODB_VERSION}/PfalciparumAnnotatedProteins_PlasmoDB-#{PLASMODB_VERSION}.fasta")
    sp = Species.find_by_name(Species.falciparum_name)
    upload_fasta_general!(fa, sp)
  end

  # OrthoMCL identifiers can be found in the gene information table.
  # this is more better than matching through names manually because there is
  # a non-redundant set of toxo genes in there, not from any one species.
  def map_toxodb_to_orthomcl_version3_temporary
    %w(ME49 GT1 VEG RH).each do |strain|
      #    %w(VEG RH).each do |strain|
      upload_gene_information_table_plumbing(
        "#{DATA_DIR}/Toxoplasma gondii/ToxoDB/#{TOXODB_VERSION}/Tgondii#{strain}Gene_ToxoDB-#{TOXODB_VERSION}.txt.gz"
      ) do |info|


        orthomcl_group = info.get_info('Temporary Ortholog Group')
        next unless orthomcl_group.match(/^OG/) #ignore the tmp ones - not sure what they mean
        
        groups = OrthomclGroup.official.find_all_by_orthomcl_name(orthomcl_group).uniq
        raise if groups.length > 1
        if groups.length == 0
          raise Exception, "Couldn't find orthomcl group #{orthomcl_group}"
        end

        # all good. create the link if I can find an entry with a name like I
        # expect
        gene_name = info.get_info('ID')
        genes = OrthomclGene.official_and_group(orthomcl_group).find_all_by_orthomcl_name(
          "tgon|#{gene_name}"
        )
        if genes.length == 0
          $stderr.puts "can't find #{gene_name} in #{orthomcl_group}, not sure I was expecting to though"
        elsif genes.length > 1
          raise
        else
          #ok, now I'm happy with orthomcl
          $stderr.puts "Happy with #{gene_name} in #{orthomcl_group}"

          codes = nil
          if strain == 'ME49'
            codes = CodingRegion.find_all_by_name_or_alternate_and_organism(gene_name, Species::TOXOPLASMA_GONDII_NAME) or raise
            raise unless codes.length == 1
          else
            # find it from the microarray column
            mic_table = info.get_table('ME49 Microarray Expression Data')
            mes = mic_table.collect do |m|
              m['ME49 Gene Model']
            end
            if mes.length == 0
              $stderr.puts "found an entry, but can't find the corresponding me49 gene from the microarray table for #{gene_name} in #{orthomcl_group}"
              next
            elsif mes.length > 1
              codes = mes.collect do |me|
                CodingRegion.find_all_by_name_or_alternate_and_organism(me, Species::TOXOPLASMA_GONDII_NAME) or raise
              end
              codes.flatten!.uniq!
            else
              codes = CodingRegion.find_all_by_name_or_alternate_and_organism(mes[0], Species::TOXOPLASMA_GONDII_NAME) or raise
              raise unless codes.length == 1
            end
          end
          codes.each do |code|
            OrthomclGeneCodingRegion.find_or_create_by_coding_region_id_and_orthomcl_gene_id(
              code.id, genes[0].id
            ) or raise
          end
        end

      end
    end
  end
end
