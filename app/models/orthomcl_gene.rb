class OrthomclGene < ActiveRecord::Base
  belongs_to :orthomcl_group
  has_many :orthomcl_gene_coding_regions
  has_many :coding_regions, :through => :orthomcl_gene_coding_regions
  has_one :orthomcl_gene_official_data
  
  MAMMALIAN_THREE_LETTER_CODES = ['hsa', 'mmu', 'rno']
  
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
    :include => {:orthomcl_group => :orthomcl_run},
    :conditions => ['orthomcl_runs.name = ?', OrthomclRun.official_run_v2_name]
  }
  named_scope :run, lambda { |run_name|
    {
      :include => {:orthomcl_group => :orthomcl_run},
      :conditions => ['orthomcl_runs.name = ?', run_name]
    }
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
    
    if !orthomcl_group
      raise Exception, "Bad linking in the database - no group associated with this orthomcl gene" 
    end
    
    if orthomcl_group.orthomcl_run.name === OrthomclRun.official_run_v2_name
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
          return CodingRegion.species_name(Species.fly_name).find_all_by_name_or_alternate(matches[1])
        else
          raise Exception, "Badly parsed dme orthomcl_name: #{inspect}"
        end
      else
        # Add the normally linked ones that don't require a workaround
        return CodingRegion.orthomcl_three_letter(matches[1]).find_all_by_name_or_alternate(name)
      end
      
    else # For non-official runs do nothing at the moment
      return []
    end
  end
  
  
  # Like compute_code_region except create the coding region if it does not
  # already exist
  def compute_coding_region!
    code = compute_coding_region
    if code
      return code
    else
      species, name = official_split(orthomcl_name)
      if !species
        return CodingRegion.create!(
          :string_id => orthomcl_name
        )
      else
        return CodingRegion.create(
          :string_id => name
        )
      end
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
      :include => {:orthomcl_group => :orthomcl_run},
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
  
  def self.official_orthomcl_apicomplexa_codes
    [
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
  end
  
  
  
  
  # Basically fill out the orthomcl_gene_coding_regions table appropriately
  # for only the official one
  def link_orthomcl_and_coding_regions(interesting_orgs=['cel'])
    goods = 0
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
        #        raise Exception, "No coding region found for #{orthomcl_gene.inspect}"
        #        $stderr.puts "No coding region found for #{orthomcl_gene.inspect}"
        next
      elsif codes.length > 1
        #ignore
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

end


class UnexpectedCodingRegionCount < Exception; end
