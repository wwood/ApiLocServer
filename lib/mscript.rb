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
    Species.find_by_name(Species.fly_name).scaffolds.each do |scaff|
      scaff.genes.each do |gene|
        gene.coding_regions.each { |g|
          g.string_id = g.string_id.strip
          #      p g.name
          g.save!
          #return g.name
        }
      end
    end
  end

  def link_mouse_genes_and_coding_regions
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

        OrthomclGeneCodingRegion.find_or_create_by_orthomcl_gene_id_and_coding_region_id(
          orthomcl_gene.id,
          a.id
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
        CodingRegionMousePhenotypeInformation.find_or_create_by_coding_region_id_and_mouse_phenotype_information_id(
          code.id,
          info.id
        )
          
      end
    end
  end
  
  def yeast_phenotype_information_to_database(filename = "#{WORK_DIR}/Gasser/Essentiality/Yeast/phenotype_data.tab")
    File.open(filename).each do |row|
      splits = row.split("\t")
      #only add phenotype info for ORFs i.e. not RNAs or phenotypes not mapped to genes
      if splits[1].match 'ORF'
        code = CodingRegion.find_by_name_or_alternate_and_organism(splits[0], Species.yeast_name)
        if !code
          raise Exception, "No coding region found for yeast id: #{splits[0]}"
        end

        #YAL001C	ORF	TFC3	S000000001	PMID: 12140549|SGD_REF: S000071347	systematic mutation set	null		S288C	inviable		
      
        info = YeastPhenoInfo.find_or_create_by_experiment_type_and_phenotype(splits[5],splits[9])
        CodingRegionYeastPhenoInfo.find_or_create_by_coding_region_id_and_yeast_pheno_info_id(
          code.id,
          info.id
        )

      end
    end
  end
  
  def drosophila_phenotypes_to_db(dir = '/home/maria/Desktop/Essentiality/Drosophila')
    
    dummy = Gene.new.create_dummy(Species.fly_name)

    #    File.open("#{dir}/fbal_fbgn_annotation_id.txt").each do |row|
    #      #first 2 lines are headers so skip  
    #      next if $. <= 2
    #      splits = row.strip.split("\t")
    #      
    #      gene_name = splits[4]
    #      allele_name = splits[0]
    #      
    #      code = CodingRegion.find_by_name_or_alternate_and_organism(gene_name, Species.fly_name)
    #      if !code
    #        code = CodingRegion.create(:gene_id => dummy.id, :string_id => gene_name)
    #      end
    #      
    #      #Then create allele gene table with
    #      ag = DrosophilaAlleleGene.find_or_create_by_allele(allele_name)
    #      
    #      CodingRegionDrosophilaAlleleGene.find_or_create_by_coding_region_id_and_drosophila_allele_gene_id(
    #        code.id,
    #        ag.id
    #      )
    #    end

    #Then create allele phenotype table. The format of the phenotype input file is as follows
    #allele_symbol allele_FBal#    phenotype       FBrf#
    #14-3-3epsilon[PL00784]  FBal0148516     embryo | germ-line clone | maternal effect  

    # skip headers, the first 6 lines
    File.open("#{dir}/allele_phenotypic_data_fb_2008_06.tsv").each do |row|
      next if $. <= 6
      splits = row.split("\t")

      #retrieve id for allele from drosophila_allele_gene_table
      name = splits[1].strip
      splits[2].split(' | ').each do |phenotype|
        g = DrosophilaAlleleGene.find_by_allele(name)
        if !g
          $stderr.puts "Couldn't find gene with allele #{name}"
        else
          ph = DrosophilaAllelePhenotype.find_or_create_by_phenotype(phenotype.strip)
          DrosophilaAllelePhenotypeDrosophilaAlleleGene.find_or_create_by_drosophila_allele_gene_id_and_drosophila_allele_phenotype_id(
            g.id, ph.id
          )
        end
      end
    end
  end
  
  
  def lethal_gene_comparisons_multple_spp(orthomcl_groups, species_orthomcl_codes)
    lethal_groups = orthomcl_groups.select do |g|
      answer = true
      species_orthomcl_codes.each do |species_code|
        # only keep groups that have a lethal gene for all species specified in species_orthomcl_codes
        g.orthomcl_genes.code(species_code).all(:select => 'distinct(id)').each do |og|
          begin
            if  !og.single_code.lethal?
              answer = false
            end
          rescue UnexpectedCodingRegionCount => e
            puts e
            answer = false #ignore?
          end
        end
      end
      answer
    end
    p lethal_groups

    return lethal_groups
  end


end

