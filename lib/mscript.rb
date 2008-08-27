require 'rio'
require 'rubygems'
require 'csv'
require 'bio'




class Mscript

  DATA_DIR = "#{ENV['HOME']}/Workspace/Rails/essentiality"
  WORK_DIR = "#{ENV['HOME']}/Workspace"

  def celegans_phenotype_information_to_database(filename = "#{WORK_DIR}/Gasser/Essentiality/Celegans/cel_wormbase_pheno.tsv")
    #dummy_gene = Gene.new.create_dummy Species.elegans_name
    first = true

    CSV.open(filename,
      'r', "\t") do |row|
      if first
        first = false
        next
      end

      code = CodingRegion.find_by_name_or_alternate_and_organism(row[0], Species.elegans_name)
      if !code
        $stderr.puts "Unknown gene found: #{row[0]}"
        next
      end

      # Observed: [WBPhenotype0000049] postembryonic_development_abnormal: experiments=1,primary=1,specific=1,observed=0

      if row[3] == nil
        next
      else
        row[3].split(' | ').each do |info|
          matches = info.match(/^Observed: \[(.+?)\] (.+?): experiments=(\d+),primary=(\d+),specific=(\d+),observed=(\d+)$/)

          if !matches
            raise Exception, "Parsing failed."
          end

          pheno = PhenotypeInformation.find_or_create_by_dbxref_and_phenotype_and_experiments_and_primary_and_specific_and_observed(

            matches[1],
            matches[2],
            matches[3],
            matches[4],
            matches[5], 
            matches[6]

          )
          
          # I want collection<< functionality, but check to make sure isn't already there otherwise
          # database will complain
          if !pheno.coding_region_ids.include?(code.id)
            pheno.coding_regions << code
          end

        end
      end
    end
  end
  
  # Upload the elegans phenotype observations to the database. Assumes all the genes already exist in the database
  def celegans_phenotype_observed_to_database(filename="#{WORK_DIR}/Gasser/Essentiality/Celegans/cel_wormbase_pheno.tsv")
    first = true

    CSV.open(filename,
      'r', "\t") do |row|
      if first
        first = false
        next
      end

      code = CodingRegion.find_by_name_or_alternate_and_organism(row[0], Species.elegans_name)
      if !code
        $stderr.puts "Unknown gene found: #{row[0]}"
        next
      end

      #Observed: [WBPhenotype0001184] fat_content_increased: experiments=1,primary=1,specific=1,observed=1

      if row[4] == nil
        next
      else
        row[4].split(' | ').each do |info|
          matches = info.match(/^Observed: \[(.+?)\] (.+?): experiments=(\d+),primary=(\d+),specific=(\d+),observed=(\d+)$/)

          if !matches
            raise Exception, "Parsing failed."
          end

          pheno = PhenotypeObserved.find_or_create_by_dbxref_and_phenotype_and_experiments_and_primary_and_specific_and_observed(

            matches[1],
            matches[2],
            matches[3],
            matches[4],
            matches[5], 
            matches[6]

          )
          
          if !pheno.coding_region_ids.include?(code.id)
            pheno.coding_regions << code
          end
        end
      end
  
    end
  end



  def fix_drosophila_genes
    Gene.all.each { |g|
      g.name = g.name.strip
      p g.name
      g.save!
      #return g.name
    }
  end

  def link_genes_and_coding_regions
    #interesting_orgs = ['dme']
    interesting_orgs = ['mmu']
    count = 0
    thing = "orthomcl_genes.orthomcl_name like '"+
      interesting_orgs.join("%' or orthomcl_genes.orthomcl_name like '")+
      "%'"
    
    # Maybe a bit heavy handed but ah well.
    OrthomclGene.all(
      :joins => {:orthomcl_group => :orthomcl_run},
      :conditions => "orthomcl_runs.name='#{OrthomclRun.official_run_v2_name}'"+
        " and (#{thing})").each do |orthomcl_gene|

      #iterate over each orthomcl protein id (eg dme|CGxxxx)
      #get gene name by first getting orthomcl protein id from OrthomclGene table and then then using that to get the gene id from the annotation information in the OrthomclGeneOfficialData table  

      e = orthomcl_gene.orthomcl_gene_official_data


      #the annotation line in orthomcl_gene_official_data =
      #|  CG1977|ENSF00000000161|Spectrin alpha chain. [Source:Uniprot/SWISSPROT;Acc:P13395] |

      #split on bars and extract first without spaces
      splits = e.annotation.split('|')
      name = splits[0].strip #this is the gene id
      #create coding region for this gene id and the protein name

      #extract protein id
      matches = orthomcl_gene.orthomcl_name.match('(.*)\|(.*)')
      pname = matches[2]

      # get primary id for gene
      a = CodingRegion.find_by_name_or_alternate_and_organism(name, Species.mouse_name)
      if !a
#        puts "#{name} not found in gene table"
        next
      else
        count += 1
        code = CodingRegion.find_or_create_by_gene_id_and_string_id(a.id, pname)   

        OrthomclGeneCodingRegion.find_or_create_by_orthomcl_gene_id_and_coding_region_id(
          orthomcl_gene.id,
          code.id
        )
      end
    end
    
    puts "Uploaded #{count} links"

  end

  
  def upload_mouse_phenotype_descriptions(filename="#{WORK_DIR}/Gasser/Essentiality/Mouse/VOC_MammalianPhenotype.rpt")
    CSV.open(filename,
      'r', "\t") do |row| 
      MousePhenoDesc.find_or_create_by_pheno_id_and_pheno_desc(row[0], row[1])
    end
  end

  def upload_mouse_phenotype_information(filename="#{WORK_DIR}/Gasser/Essentiality/Mouse/MGI_PhenotypicAllele.rpt")
    #add gene ids from phenotype file to gene table

    #Example line from MGI phenotype file
    #MGI:3702935        1190005F20Rik<Gt(W027A02)Wrst>  gene trap W027A02, Wolfgang Wurst       Gene trapped    17198746        MGI:1916185     1190005F20Rik XM_355244       ENSMUSG00000053286      MP:0005386,MP:0005389

    dummy = Gene.new.create_dummy(Species.mouse_name)
    
    File.open(filename).
      each do |row2|

      # skip headers, the first 7 lines
      next if $. <= 7
      splits = row2.split("\t")
      #skip line if no ensembl gene id
      ensembl = splits[8].strip
      phenotype_ids = splits[9].strip
      
      if !ensembl or !phenotype_ids
        raise Exception, "Badly handled line: #{ensembl} #{phenotype_ids} - #{row2}"
      end
      
      code = CodingRegion.find_by_name_or_alternate_and_organism(ensembl, Species.mouse_name)
      if !code
        code =CodingRegion.create(:string_id => ensembl, :gene => dummy)
      end
      
      
      phenotype_ids.split(',').each do |pheno_id|
        # get primary id for phenotype id
        i = MousePhenoDesc.find_by_pheno_id(pheno_id.strip)
        
        raise Exception, "#{pheno_id}" if !i
        
        info = MousePhenotypeInformation.find_or_create_by_mgi_allele_and_allele_type_and_mgi_marker_and_mouse_pheno_desc_id(
          splits[0], splits[3], splits[5], i.id
        )
        # find or create association
        CodingRegionMousePhenotypeInformations.find_or_create_by_coding_region_id_and_mouse_phenotype_information_id(
          code.id,
          info.id
        )
          
      end
    end
  end
  
  def yeast_phenotype_information_to_database 
    dummy_gene = Gene.new.create_dummy('yeast dummy')
   
    File.open("#{WORK_DIR}/Gasser/Essentiality/Yeast/phenotype_data.tab").each do |row|
      splits = row.split("\t")
      #only add phenotype info for ORFs i.e. not RNAs or phenotypes not mapped to genes
      if splits[1].match 'ORF'
        code = CodingRegion.find_or_create_by_string_id_and_gene_id(
          splits[0],
          dummy_gene.id
        )

        #YAL001C	ORF	TFC3	S000000001	PMID: 12140549|SGD_REF: S000071347	systematic mutation set	null		S288C	inviable		
      
        YeastPhenoInfo.find_or_create_by_coding_region_id_and_experiment_type_and_phenotype(code.id,splits[5],splits[9])

      end
    end
  end
  

  
end

