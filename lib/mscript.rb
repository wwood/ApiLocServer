require 'rio'
require 'rubygems'
require 'csv'
require 'bio'




class Mscript

  DATA_DIR = "#{ENV['HOME']}/Workspace/Rails/essentiality"
  WORK_DIR = "#{ENV['HOME']}/Workspace"

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

