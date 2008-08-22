require 'rio'
require 'rubygems'
require 'csv'
require 'bio'




class Mscript

  DATA_DIR = "#{ENV['HOME']}/Workspace/Rails/essentiality"
  WORK_DIR = "#{ENV['HOME']}/Workspace"
  
  def celegans_phenotype_information_to_database(filename = "#{WORK_DIR}/Gasser/Essentiality/Celegans/cel_wormbase_pheno.tsv")
    dummy_gene = Gene.new.create_dummy('worm dummy')
    first = true

    CSV.open(filename,
      'r', "\t") do |row|
      if first
        first = false
        next
      end

      code = CodingRegion.find_or_create_by_string_id_and_gene_id(
        row[0],
        dummy_gene.id
      )

      # Observed: [WBPhenotype0000049] postembryonic_development_abnormal: experiments=1,primary=1,specific=1,observed=0

      if row[3] == nil
        next
      else
        row[3].split(' | ').each do |info|
          matches = info.match(/^Observed: \[(.+?)\] (.+?): experiments=(\d+),primary=(\d+),specific=(\d+),observed=(\d+)$/)

          if !matches
            raise Exception, "Parsing failed."
          end

          PhenotypeInformation.find_or_create_by_coding_region_id_and_dbxref_and_phenotype_and_experiments_and_primary_and_specific_and_observed(

            code.id,
            matches[1],
            matches[2],
            matches[3],
            matches[4],
            matches[5], 
            matches[6]

          )

        end
      end
    end
  end
  
  
  def celegans_phenotype_observed_to_database(filename="#{WORK_DIR}/Gasser/Essentiality/Celegans/cel_wormbase_pheno.tsv")
    dummy_gene = Gene.new.create_dummy('worm dummy')
    first = true

    CSV.open(filename,
      'r', "\t") do |row|
      if first
        first = false
        next
      end

      code = CodingRegion.find_or_create_by_string_id_and_gene_id(
        row[0],
        dummy_gene.id
      )

      #Observed: [WBPhenotype0001184] fat_content_increased: experiments=1,primary=1,specific=1,observed=1

      if row[4] == nil
        next
      else
        row[4].split(' | ').each do |info|
          matches = info.match(/^Observed: \[(.+?)\] (.+?): experiments=(\d+),primary=(\d+),specific=(\d+),observed=(\d+)$/)

          if !matches
            raise Exception, "Parsing failed."
          end

          PhenotypeObserved.find_or_create_by_coding_region_id_and_dbxref_and_phenotype_and_experiments_and_primary_and_specific_and_observed(

            code.id,
            matches[1],
            matches[2],
            matches[3],
            matches[4],
            matches[5], 
            matches[6]

          )

        end
      end
    end
  
  end
  

  def drosophila_allele_gene_to_database

    #Allele ID      Allele Symbol   Gene ID         Gene Symbol     Annotation ID
    #FBal0000001     alpha-Spec[1]   FBgn0250789     alpha-Spec      CG1977
    first = true

    CSV.open("#{WORK_DIR}/Gasser/Essentiality/Drosophila/fbal_fbgn_annotation_id.txt", 'r', "\t") do |row| 
      if first or row === ''
        first = false
        next
      end
     
      DrosophilaAlleleGene.find_or_create_by_allele_and_gene(row[0], row[4])
    end
  end



  def drosophila_phenotype_info_to_database

    ###allele_symbol allele_FBal#    phenotype       FBrf#
    #14-3-3epsilon[PL00784]  FBal0148516     embryo | germ-line clone | maternal effect   

    # skip headers, the first 6 lines
    File.open("#{WORK_DIR}/Gasser/Essentiality/Drosophila/allele_phenotypic_data_fb_2008_06.tsv").each do |row|
      next if $. <= 6
      splits = row.split("\t")

      #retrieve info for allele from drosophila_allele_gene_table 
      name = splits[1]
      a = DrosophilaAlleleGene.find_by_allele(name)
      if !a
        puts "#{name}"
      else
        DrosophilaAllelePhenotype.find_or_create_by_drosophila_allele_gene_id_and_phenotype(a.id, splits[2])
      end
    end

  end


  def mouse_phenotype_info_to_database
     
    CSV.open("#{WORK_DIR}/Gasser/Essentiality/Mouse/MRK_Ensembl_Pheno.rpt", 'r', "\t") do |row| 
      if row[3].match ','
        row[3].split(',').each do |info|       
          MousePhenotypeInfo.find_or_create_by_mgi_and_gene_and_phenotype(row[0], info, row[5])
        end
      else
        MousePhenotypeInfo.find_or_create_by_mgi_and_gene_and_phenotype(row[0], row[3], row[5])
      end


    end
  end

  def mouse_phenotype_info_to_database

    #Example line from MGI phenotype file
    #MGI:3702935	1190005F20Rik<Gt(W027A02)Wrst>	gene trap W027A02, Wolfgang Wurst	Gene trapped	17198746	MGI:1916185	1190005F20Rik	XM_355244	ENSMUSG00000053286	MP:0005386,MP:0005389  

    File.open("#{WORK_DIR}/Gasser/Essentiality/Mouse/MGI_PhenotypicAllele.rpt").each do |row|    

      # skip headers, the first 7 lines
      next if $. <= 7
      splits = row.split("\t")
      if splits[9].match ','
        splits[9].split(',').each do |info|       
          MousePhenoInfo.find_or_create_by_mgi_allele_and_allele_type_and_mgi_marker_and_gene_and_phenotype(splits[0], splits[3], splits[5], splits[8], info)
        end
      else
        MousePhenoInfo.find_or_create_by_mgi_allele_and_allele_type_and_mgi_marker_and_gene_and_phenotype(splits[0], splits[3], splits[5], splits[8], splits[9])
      end


    end
  end

  def drosophila_phenotypes_to_db

    File.open("/home/maria/Desktop/Essentiality/Drosophila/fbal_fbgn_annotation_id.txt").each do |row|
      #first 2 lines are headers so skip   
      next if $. <= 2
      splits = row.split("\t")
      g = Gene.find_or_create_by_name(splits[4])
      #Then create allele gene table with
      DrosophilaAlleleGene.find_or_create_by_allele_and_gene_id(splits[0], g.id) 
    end

    #Then create allele phenotype table. The format of the phenotype input file is as follows
    #allele_symbol allele_FBal#    phenotype       FBrf#
    #14-3-3epsilon[PL00784]  FBal0148516     embryo | germ-line clone | maternal effect   

    # skip headers, the first 6 lines
    File.open("/home/maria/Desktop/Essentiality/Drosophila/allele_phenotypic_data_fb_2008_06.tsv").each do |row2|
      next if $. <= 6
      splits2 = row2.split("\t")

      #retrieve id for allele from drosophila_allele_gene_table 
      name = splits2[1]
      a = DrosophilaAlleleGene.find_by_allele(name)
      if !a
        $stderr.puts "No gene id found for allele #{name}"
      else
        DrosophilaAllelePhenotype.find_or_create_by_drosophila_allele_gene_id_and_phenotype(a.id, splits2[2])
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
    interesting_orgs = ['dme']
    thing = "orthomcl_genes.orthomcl_name like '"+
      interesting_orgs.join("%' or orthomcl_genes.orthomcl_name like '")+
      "%'"
    
    # Maybe a bit heavy handed but ah well.
    OrthomclGene.find(:all, 
      :include => {:orthomcl_group => :orthomcl_run},
      :conditions => "orthomcl_runs.name='#{OrthomclRun.official_run_v2_name}'"+
        " and (#{thing})").each do |orthomcl_gene|

      #iterate over each orthomcl protein id (eg dme|CGxxxx)
      #get gene name by first getting orthomcl protein id from OrthomclGene table and then then using that to get the gene id from the annotation information in the OrthomclGeneOfficialData table  

      e = OrthomclGeneOfficialData.find_by_orthomcl_gene_id(orthomcl_gene.id)


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
      a = Gene.find_by_name(name)
      if !a
        puts "#{name} not found in gene table"
        next
      else
        code = CodingRegion.find_or_create_by_gene_id_and_string_id(a.id, pname)   

        OrthomclGeneCodingRegion.find_or_create_by_orthomcl_gene_id_and_coding_region_id(
          orthomcl_gene.id,
          code.id
        )
      end
    end

  end

  

end

