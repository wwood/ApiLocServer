class OrthomclGene < ActiveRecord::Base
  has_many :orthomcl_gene_orthomcl_group_orthomcl_runs, :dependent => :destroy
  has_many :orthomcl_groups, :through => :orthomcl_gene_orthomcl_group_orthomcl_runs
  has_one :orthomcl_run, :through => :orthomcl_gene_orthomcl_group_orthomcl_runs
  
  has_many :orthomcl_gene_coding_regions
  has_many :coding_regions, :through => :orthomcl_gene_coding_regions
  has_one :orthomcl_gene_official_data
  
  MAMMALIAN_THREE_LETTER_CODES = ['hsa', 'mmu', 'rno']
  OFFICIAL_ORTHOMCL_APICOMPLEXAN_CODES = [
    'cpa',
    'cho',
    'tgo',
    'pfa',
    'pyo',
    'pvi',
    'pkn',
    'pbe',
    'pch',
    'the',
    'tan'
  ]
  
  named_scope :code, lambda { |three_letter_species_code| {
      :conditions => ['orthomcl_name like ?', "#{three_letter_species_code}%"]
    }}
  #  alias_method(:three_letter_code, :code)
  named_scope :codes, lambda { |three_letter_species_codes| 
    pre = 'orthomcl_genes.orthomcl_name like ?'
    post = ["#{three_letter_species_codes[0]}%"]
    three_letter_species_codes.each {|code|
      pre += ' or orthomcl_genes.orthomcl_name like ?'
      post.push ["#{code}%"]
    }
    {:conditions => [pre, post].flatten}
  }
  #alias_method(:three_letter_codes, :codes)
  named_scope :official, {
    :include => :orthomcl_run,
    :conditions => ['orthomcl_runs.name = ?', OrthomclRun.official_run_v2_name]
  }
  named_scope :run, lambda { |run_name|
    {
      :include => :orthomcl_run,
      :conditions => ['orthomcl_runs.name = ?', run_name]
    }
  }
  named_scope :no_group, {
    :include => :orthomcl_gene_orthomcl_group_orthomcl_runs,
    :conditions => 'orthomcl_gene_orthomcl_group_orthomcl_runs.orthomcl_group_id is NULL'
  }
  named_scope :apicomplexan, lambda {
    three_letter_species_codes = OFFICIAL_ORTHOMCL_APICOMPLEXAN_CODES
    pre = 'orthomcl_genes.orthomcl_name like ?'
    post = ["#{three_letter_species_codes[0]}%"]
    three_letter_species_codes.each {|code|
      pre += ' or orthomcl_genes.orthomcl_name like ?'
      post.push ["#{code}%"]
    }
    {:conditions => [pre, post].flatten}
  }
  
  def accepted_database_id
    matches = orthomcl_name.match('pfa\|(.*)$')
    if matches
      return matches[1]
    end
    
    matches = orthomcl_name.match('ath\|(.*)$')
    if matches
      return matches[1].upcase
    end
    
    return nil
  end
  
  # Get the coding region that is associated with this gene, whether it is a
  # 
  def compute_coding_regions    
    if orthomcl_run.name === OrthomclRun.official_run_v2_name
      matches = orthomcl_name.match('(.*)\|(.*)')
      
      if !matches
        raise Exception, "Badly parsed orthomcl official type name: #{orthomcl_name}"
      end
      
      #      # Only compute interesti'ng cases
      #      if !(['pfa','pvi','the','tan','cpa','cho','ath'].include?(matches[1]))
      #        return nil #meh for the moment, don't want to waste time
      #      end
      
      name = matches[2]
      
      #species specific workarounds below
      if matches[1] === 'dme'
        # for drosophila drop the -PA or -PB at the end of it
        matches = name.match(/^(.*)\-(.*)$/)
        if matches
          return CodingRegion.find_all_by_name_or_alternate_and_species(matches[1], Species.fly_name)
        else
          raise Exception, "Badly parsed dme orthomcl_name: #{inspect}"
        end
      elsif matches[1] == 'mmu'
        #iterate over each orthomcl protein id (eg dme|CGxxxx)
        #get gene name by first getting orthomcl protein id from OrthomclGene table and then then using that to get the gene id from the annotation information in the OrthomclGeneOfficialData table  

        e = orthomcl_gene_official_data
        raise Exception, "Data bug in mmu orthomcl data - no orthomcl_gene_official_data found. Has it already been uploaded like it should be?" if e.nil?

        #the annotation line in orthomcl_gene_official_data =
        #|  CG1977|ENSF00000000161|Spectrin alpha chain. [Source:Uniprot/SWISSPROT;Acc:P13395] |

        #split on bars and extract first without spaces
        splits = e.annotation.split('|')
        name = splits[0].strip #this is the gene id
        #create coding region for this gene id and the protein name

        #extract protein id
        matches = orthomcl_name.match('(.*)\|(.*)')
        pname = matches[2]

        # get primary id for gene
        return CodingRegion.find_all_by_name_or_alternate_and_species(name, Species.mouse_name)
      else
        # Add the normally linked ones that don't require a workaround
        sp = Species.find_by_orthomcl_three_letter matches[1]
        return CodingRegion.find_all_by_name_or_alternate_and_species(name, sp.name)
      end
    else # For non-official runs do nothing at the moment
      return []
    end
  end
  
  # With the official names, split them up into the 2 parts
  # return nil if it didn't match properly
  def official_split(name)
    ems = name.match('(.*)\|(.*)')
    if ems
      return ems[1], ems[2]
    else
      return nil
    end
  end
  
  
  # Map elegans coding regions to orthomcl_genes using the table. Assumes that there is
  # alternate coding region names like WBGene00013989
  def create_elegans_coding_region_links
    count = 0
    OrthomclGene.all(
      :include => [:orthomcl_group, :orthomcl_run],
      :conditions => "orthomcl_genes.orthomcl_name like 'cel%' and orthomcl_runs.name = '#{OrthomclRun.official_run_v2_name}'"
    ).each do |og|
      
      codes = og.compute_coding_regions
      
      
      if codes.length == 0
        $stderr.puts "Failed to find coding region: #{real}"
        next
      elsif codes.length > 1
        $stderr.puts "Too many coding regions found for #{real}: #{codes.inspect}"
        next
      end
      codes[0]
      
      
      ogc = OrthomclGeneCodingRegion.find_or_create_by_coding_region_id_and_orthomcl_gene_id(
        code.id,
        og.id
      )
      if !ogc
        raise Exception, "Problem uploading final: #{ogc.orthomcl_name}"
      end
      
      count += 1
    end
    
    puts "Created/Verified #{count} coding regions"
  end
  
  
  # Convenience method so you can map to a single coding region, as is most often done
  # Raise Exception if 0 or (2 or more) coding regions are found connected
  def single_code
    codes = coding_regions(:reload => true)
    
    if coding_regions.length != 1
      raise UnexpectedCodingRegionCount, "Unexpected number of coding regions found for #{inspect}: #{codes.inspect}"
    end
    return codes[0]
  end
  
  # Get the first coding region associated with this orthomcl_gene like single_code,
  # but don't raise an exception if none is found, though still do this if more than 
  # one is found
  def single_code!
    codes = coding_regions(:reload => true)
    
    if coding_regions.length > 1
      raise UnexpectedCodingRegionCount, "Unexpected number of coding regions found for #{inspect}: #{codes.inspect}"
    end
    return codes[0]    
  end
  
  def self.official_orthomcl_apicomplexa_codes
    OFFICIAL_ORTHOMCL_APICOMPLEXAN_CODES
  end
    
  
  
  # Basically fill out the orthomcl_gene_coding_regions table appropriately
  # for only the official one

  def link_orthomcl_and_coding_regions(interesting_orgs=['cel'])
    goods = 0; nones = 0; too_manies = 0
    
    if !interesting_orgs or interesting_orgs.empty?
      #    interesting_orgs = ['pfa','pvi','the','tan','cpa','cho','ath']
      #    interesting_orgs = ['pfa','pvi','the','tan','cpa','cho']
      #    interesting_orgs = ['ath']
      interesting_orgs = ['cel']
    end
    
    puts "linking genes for species: #{interesting_orgs.inspect}"
    
    # Maybe a bit heavy handed but ah well.
    OrthomclGene.codes(interesting_orgs).official.all.each do |orthomcl_gene|
    
      codes = orthomcl_gene.compute_coding_regions
      if !codes or codes.length == 0
        #        next #ignore for the moment
        #                raise Exception, "No coding region found for #{orthomcl_gene.inspect}"
        #        $stderr.puts "No coding region found for #{orthomcl_gene.inspect}"
        nones += 1
        next
      elsif codes.length > 1
        #ignore
        #        raise Exception, "Too many coding regions found for #{orthomcl_gene.orthomcl_name}" 
        $stderr.puts "Too many coding regions found for #{orthomcl_gene.orthomcl_name}"
        too_manies += 1
        next
      else
        code = codes[0]
        goods += 1
      
        OrthomclGeneCodingRegion.find_or_create_by_orthomcl_gene_id_and_coding_region_id(
          orthomcl_gene.id,
          code.id
        )
      end
    end
    
    puts "Properly linked #{goods} coding regions. None found #{nones}. Too many found #{too_manies}."
  end
  
  # same as link_orthomcl_and_coding_regions, except don't
  # require the orthomcl genes to be linked to the official one. This
  # makes it include, then, all genes that have not been put into an
  # orthomcl group
  
  def link_orthomcl_and_coding_regions_loose(interesting_orgs=['mmu'], warn=true)
    # def link_orthomcl_and_coding_regions_loose(interesting_orgs=['sce'], warn=false)
    #def link_orthomcl_and_coding_regions_loose(interesting_orgs=['cel'], warn=false)
    goods = 0
    if !interesting_orgs or interesting_orgs.empty?
      #    interesting_orgs = ['pfa','pvi','the','tan','cpa','cho','ath']
      #    interesting_orgs = ['pfa','pvi','the','tan','cpa','cho']
      #    interesting_orgs = ['ath']
      #interesting_orgs = ['cel']
      interesting_orgs = ['mmu']
    end
    
    puts "linking genes for species: #{interesting_orgs.inspect}"
    
    # Maybe a bit heavy handed but ah well.
    OrthomclGene.codes(interesting_orgs).all.each do |orthomcl_gene|
    
      org, name = official_split(orthomcl_gene.orthomcl_name)
      if org.nil? #error check
        raise Exception, "Couldn't parse orthomcl name: #{orthomcl_gene.orthomcl_name}"
      end
      
      species = Species.find_by_orthomcl_three_letter(org)
      raise if !species
      codes = CodingRegion.find_all_by_name_or_alternate_and_species(name, species.name)
      if !codes or codes.length == 0
        if warn
          $stderr.puts "No coding region found for #{orthomcl_gene.inspect}"
        end
        next
      elsif codes.length > 1
        if warn
          $stderr.puts "Multiple coding regions found for #{orthomcl_gene.inspect}"
        end
        next
      else
        code = codes[0]
        goods += 1
      end
      
      OrthomclGeneCodingRegion.find_or_create_by_orthomcl_gene_id_and_coding_region_id(
        orthomcl_gene.id,
        code.id
      )
    end  
    puts "Properly linked #{goods} coding regions"
  end
  
  def code?(official_orthomcl_species_code)
    s = official_split(orthomcl_name)
    return nil if s.nil?
    return official_orthomcl_species_code == s[0]
  end

  class UnexpectedCodingRegionCount < StandardError; end
end



