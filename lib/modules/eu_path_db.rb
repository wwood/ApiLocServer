# Methods associated mainly with uploading data from PlasmoDB and ToxoDB etc.

require 'eupathdb_gene_information_table'
require 'zlib'
require 'species_data'

class BScript
  PLASMODB_VERSION = SpeciesData::SOURCE_VERSIONS['PlasmoDB']
  TOXODB_VERSION = SpeciesData::SOURCE_VERSIONS['ToxoDB']
  CRYPTODB_VERSION = SpeciesData::SOURCE_VERSIONS['CryptoDB']
  
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
  
  # low level method. don't create coding regions or GO terms, just
  # parse the file
  def upload_gene_information_table_plumbing(filename)
    oracle = nil
    
    # We may or may not want a gz file to be uploaded
    if filename.match(/gz$/)
      oracle = EuPathDBGeneInformationTable.new(Zlib::GzipReader.open(filename))
    else
      oracle = EuPathDBGeneInformationTable.new(File.open(filename,'r'))
    end
    
    oracle.each do |info|
      yield info #have to give a block, otherwise why are you calling me?
    end
  end
  
  # High level for general EuPathDB use. Find coding regions and upload
  # GO terms associated and give a yield for further uploads on a gene
  # entry basis.
  def upload_gene_information_table(species, gzfile)
    upload_gene_information_table_coding_region(species, gzfile) do |info, code|
      
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
  
  # medium level method for gene information table - takes a gzfile
  # path and species and a code fragment to execute for each. Does nothing
  # else though - no GO terms and shit
  def upload_gene_information_table_coding_region(species, gzfile)
    upload_gene_information_table_plumbing(gzfile) do |info|
      # find the gene
      gene_id = info.get_info('Gene Id')
      if info.get_info('Gene') # Toxo is 'ID', whereas falciparum is 'Gene'.
        raise unless gene_id.nil?
        gene_id = info.get_info('Gene')
      end
      code = CodingRegion.fs(gene_id, species.name)
      unless code and code.species.name == species.name
        $stderr.puts "Couldn't find coding region `#{gene_id}, skipping"
        next
      end
      
      yield info, code if block_given?
    end
  end
  
  
  # Use the gene table to upload the GO terms to the database, including
  # old release 4 identifiers
  def upload_gondii_gene_table_to_database
    upload_gene_information_table(
                                  Species.find_by_name(Species::TOXOPLASMA_GONDII),
      "#{DATA_DIR}/Toxoplasma gondii/genome/ToxoDB/#{TOXODB_VERSION}/TgondiiME49Gene_ToxoDB-#{TOXODB_VERSION}.txt"
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
      
      # Add the mass spec data from the table to the database
      proteomic_name_to_pubmed = ProteomicExperiment::TOXOPLASMA_NAME_TO_PUBLICATION_HASH
      mass_spec_table = info.get_table('Mass Spec.-based Expression Evidence')
      mass_spec_table.each do |row|
        experiment = row['Experiment']
        # temporary typo fix
        experiment = 'MS Tachyzoite Membrane Protein with Biotinlyation Purification 05-22-2007' if experiment == 'MS Tachyzoite Membrane Protein with  Biotinlyation Purification 05-22-2007'
        experiment = 'MS Carruthers 2 distinct peptides' if experiment == 'MS Carruthers 2destinct peptides'
        
        if experiment.nil?
          raise Exception, "Failed to parse proteomics experiment table (programming error?): #{mass_spec_table.inspect} from #{code.string_id}"
        end
        
        # Add T.gondii to the front because that is convention
        experiment = "T. gondii #{experiment}"
        
        unless proteomic_name_to_pubmed[experiment]
          $stderr.puts "Unable to classify proteomic experiment: '#{experiment}' into a known publication"
          next
        end
        pub = nil
        if proteomic_name_to_pubmed[experiment].kind_of?(String)
          pub = Publication.find_or_create_by_url(proteomic_name_to_pubmed[experiment])
        elsif proteomic_name_to_pubmed[experiment].kind_of?(Integer)
          pub = Publication.find_or_create_by_pubmed_id(proteomic_name_to_pubmed[experiment])
        else
          raise
        end
        raise unless pub
        e = ProteomicExperiment.find_or_create_by_name_and_publication_id(
                                                                          experiment, pub.id
        )
        raise unless ProteomicExperimentResult.find_or_create_by_coding_region_id_and_proteomic_experiment_id(
                                                                                                              code.id, e.id
        ).id
      end
    end
  end
  
  # Upload the microarray percentiles from the different strains
  def gondii_archetypal_lineage_percentiles_to_database
    #TABLE: Three archetypal T. gondii lineages - Percentiles
    #[Strain]	[Percentile]
    #VEG	11.5
    #CTG	23.2
    #Prugniaud	71.9
    #RH	78.7
    #GT1	78.2
    #ME49	82.7
    species_data = SpeciesData.new(Species::TOXOPLASMA_GONDII_NAME)
    array = Microarray.find_or_create_by_description(Microarray::TOXOPLASMA_ARCHETYPAL_LINEAGE_PERCENTILES_NAME)
    upload_gene_information_table_coding_region(
                                                Species.find_by_name(species_data.name),
    species_data.gene_information_gzfile_path
    ) do |info, code|
      # Find the timepoints
      table = info.get_table('Three archetypal T. gondii lineages - Percentiles')
      raise unless table
      
      table.each do |row|
        timepoint = MicroarrayTimepoint.find_or_create_by_microarray_id_and_name(
                                                                                 array.id, row['Strain']
        ) or raise
        MicroarrayMeasurement.find_or_create_by_microarray_timepoint_id_and_coding_region_id_and_measurement(
                                                                                                             timepoint.id, code.id, row['Percentile']
        ) or raise
      end
    end
  end
  #
  #  def gondii_proteomics_data_to_database
  #    species_data = SpeciesData.new(Species::TOXOPLASMA_GONDII_NAME)
  #
  #    upload_gene_information_table_coding_region(
  #      Species.find_by_name(species_data.name),
  #      species_data.gene_information_gzfile_path
  #    ) do |info, code|
  #      table = info.get_table('Mass Spec.-based Expression Evidence')
  #      table.each do |row|
  #        experiment = ProteomicExperiment.find_or_create_by_name(row['Experiment Name']) or raise
  #        ProteomicExperimentPeptide.find_or_create_by_peptide_and_coding_region_id_and_proteomic_experiment_id(
  #          row['Sequences'],
  #          code.id,
  #          experiment.id
  #        ) or raise
  #        ProteomicExperimentResult.find_or_create_by_coding_region_id_and_proteomic_experiment_id_and_number_of_peptides_and_spectrum(
  #          code.id,
  #          experiment.id,
  #          row['Sequence Count'],
  #          row['Spectrum Count']
  #        ) or raise
  #      end
  #    end
  #  end
  
  def gondii_tachyzoite_and_not_est_counts_to_database
    species = Species.find_by_name(Species::TOXOPLASMA_GONDII_NAME)
    FasterCSV.foreach(
      "#{DATA_DIR}/Toxoplasma gondii/transcriptome/ToxoDB/5.2/tachyzoite_only_ests_ToxoDB5.2.txt",
      :col_sep => "\t",
      :headers => true
    ) do |row|
      code = CodingRegion.fs(row[0],species.name) or raise
      TachyzoiteEstCount.find_or_create_by_coding_region_id_and_value(
                                                                      code.id,
                                                                      row[1].to_i
      )
    end
    FasterCSV.foreach(
      "#{DATA_DIR}/Toxoplasma gondii/transcriptome/ToxoDB/5.2/all_except_tachyzoite_ests_ToxoDB5.2.txt",
      :col_sep => "\t",
      :headers => true
    ) do |row|
      code = CodingRegion.fs(row[0],species.name) or raise
      NonTachyzoiteEstCount.find_or_create_by_coding_region_id_and_value(
                                                                         code.id,
                                                                         row[1].to_i
      )
    end
  end
  
  def falciparum_gene_table_to_database
    species_data = SpeciesData.new(Species::FALCIPARUM_NAME)
    
    # Setup Winzeler data
    max_microarray = Microarray.find_or_create_by_description Microarray::WINZELER_IRBC_SPZ_GAM_MAX_PERCENTILE
    max_timepoint = MicroarrayTimepoint.find_or_create_by_name_and_microarray_id(
                                                                                 WINZELER_IRBC_SPZ_GAM_MAX_PERCENTILE_TIMEPOINT,
                                                                                 max_microarray.id
    )
    
    upload_gene_information_table(Species.find_by_name(Species::FALCIPARUM_NAME),
    species_data.gene_information_path
    ) do |info, code|
      # Upload Winzeler gene table stuffs
      max_percentile = info['Pf-iRBC+Spz+Gam max expr %ile (Affy)']
      unless max_percentile == 'null'
        percent = max_percentile.to_f
        MicroarrayMeasurement.find_or_create_by_coding_region_id_and_microarray_timepoint_id_and_measurement(
                                                                                                             code.id, max_timepoint.id, percent
        )
      end
    end
  end
  
  def upload_apiloc_from_scratch
#    go_to_database
#    download_uniprot_data
#    uniprot_to_database
#    download_orthomcl
#    orthomcl_to_database
#    
#    # Upload basic gene identifiers
#    upload_apiloc_gffs
#    upload_gondii_gene_table_to_database
#    upload_apiloc_fasta_files
#    
#    proteomics_to_database
#    
#    yeastgenome_ids_to_database
#    elegans_wormbase_identifiers
#    uniprot_ensembl_databases
#    uniprot_refseq_databases
#    tbrucei_names_to_database
#    dicystelium_names_to_database
#    drosophila_ensembl_metazoa
#    
#    Species.new.update_known_four_letters
#    OrthomclGene.new.link_orthomcl_and_coding_regions(
#      "hsap mmus scer drer crei atha dmel cele rnor spom tbru",
#      :accept_multiple_coding_regions => true
#    )
#    OrthomclGene.new.link_orthomcl_and_coding_regions(
#                                                      Species::APICOMPLEXAN_NAMES.collect { |a|
#      Species.find_by_name(a).orthomcl_three_letter
#    }, {:verbose => true, :warn => true}
#    )
    
    LocalisationSpreadsheet.new.upload
  end
  
  def upload_apiloc_gffs
    falciparum_to_database
    berghei_to_database
    yoelii_to_database
    vivax_to_database
    chabaudi_to_database
    knowlesi_to_database
    gondii_to_database
    neospora_caninum_to_database
    cryptosporidium_parvum_to_database
    cryptosporidium_hominis_to_database
    cryptosporidium_muris_to_database
    theileria_parva_to_database
    theileria_annulata_to_database
    babesia_bovis_to_database
  end
  
  def upload_apiloc_fasta_files
    falciparum_fasta_to_database
    berghei_fasta_to_database
    yoelii_fasta_to_database
    vivax_fasta_to_database
    chabaudi_fasta_to_database
    knowlesi_fasta_to_database
    gondii_fasta_to_database
    neospora_caninum_fasta_to_database
    cryptosporidium_parvum_fasta_to_database
    cryptosporidium_hominis_fasta_to_database
    cryptosporidium_muris_fasta_to_database
    theileria_parva_fasta_to_database
    theileria_annulata_fasta_to_database
    babesia_bovis_fasta_to_database
  end
  
  def temporary_fix_for_apiloc3
    uniprot_ensembl_databases
    uniprot_refseq_databases
    
    OrthomclGene.new.link_orthomcl_and_coding_regions(
      "rnor spom",
      :accept_multiple_coding_regions => true
    )
  end
  
  def upload_proteomic_data
    food_vacuole_proteome_to_database
    maurers_cleft_proteome_to_database
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
  
  # a catch-all for the pesky uploading of gff and amino acid sequences
  def method_missing(symbol, *args)
    meth = symbol.to_s
    if matches = meth.match(/(.+)_fasta_to_database$/)
      spd = SpeciesData.new(matches[1])
      fa = EuPathDb2009.new(
                            spd.fasta_file_species_name,
                            spd.sequencing_centre_abbreviation
      ).load(spd.protein_fasta_path)
      sp = Species.find_by_name(spd.name)
      upload_fasta_general!(fa, sp)
    elsif matches = meth.match(/(.+)_to_database$/)
      spd = SpeciesData.new(matches[1])
      apidb_species_to_database(
                                spd.name,
                                spd.gff_path
      )
    else
      super
    end
  end
  
  def download(database_name=nil)
    # by default, download everything
    if database_name.nil?
      SpeciesData::DATABASES.each do |d|
        download d
      end
    else
      # Download the new files from the relevant database
      species_data_from_database(database_name).each do |spd|
        spd.directories_for_mkdir.each do |directory|
          unless File.exists?(directory)
            Dir.mkdir(directory)
          end
        end
        
        Dir.chdir(spd.local_download_directory) do
          #          $stderr.puts "chdir: #{Dir.pwd}"
          # protein
          unless File.exists?(spd.protein_fasta_filename)
            `wget #{spd.eu_path_db_fasta_download_directory}/#{spd.protein_fasta_filename}`
          end
          # gff
          unless File.exists?(spd.gff_filename)
            `wget #{spd.eu_path_db_gff_download_directory}/#{spd.gff_filename}`
          end
          # transcripts
          unless File.exists?(spd.transcript_fasta_filename)
            `wget #{spd.eu_path_db_fasta_download_directory}/#{spd.transcript_fasta_filename}`
          end
          # gene information table
          unless File.exists?(spd.gene_information_filename)
            `wget '#{spd.eu_path_db_txt_download_directory}/#{spd.gene_information_filename}'`
          end
          # genomic
          unless File.exists?(spd.genomic_fasta_filename)
            `wget '#{spd.eu_path_db_fasta_download_directory}/#{spd.genomic_fasta_filename}'`
          end          
        end
      end
    end
  end
  
  def species_data_from_database(eupathdb_database_name)
    database_name = eupathdb_database_name.downcase
    raise unless SpeciesData::DATABASES.reach.downcase.include?(database_name)
    species_names = {
      'plasmodb' => Species::PLASMODB_SPECIES_NAMES,
      'toxodb' => Species::TOXODB_SPECIES_NAMES,
      'cryptodb' => Species::CRYPTODB_SPECIES_NAMES,
      'piroplasmadb' => Species::PIROPLASMADB_SPECIES_NAMES
    }[database_name]
    species_names.collect do |name|
      SpeciesData.new(name)
    end
  end
  
  # A generalised upgrade method for upgrading EuPathDB data in gnr
  def upgrade(database_name)
    database_name.downcase!
    # Destroy all the species in the database, using the named_scope
    $stderr.puts "might want to change the destroy to a database delete so the database can do the work way way faster?"
    return
    Species.send(database_name.to_sym).all.reach.destroy
    
    # downloads go through only if the files don't already exist,
    # so this isn't wasteful
    download(database_name)
    
    # upload each gff, amino acid, and nucleotide
    spds = species_data_from_database(database_name)
    spds.each do |spd|
      # upload gff
      send("#{spd.name.gsub(' ','_')}_to_database".to_sym)
      
      # upload amino acids
      send("#{spd.name.gsub(' ','_')}_fasta_to_database".to_sym)
      
      # upload nucleotide sequences
      #      send("spd.name.gsub(' ','_')_fasta_to_database".to_sym)
    end
    
    # upload localisation data
  end
  
  def eupathdb_links
    puts ["Species", "ID","URL"].join("\t")
    CodingRegion.all(:joins => :expression_contexts, :select => 'distinct(coding_regions.*)').each do |code|
      puts [code.species.name, code.string_id, code.apiloc_url].join("\t")
    end
  end
  
end
