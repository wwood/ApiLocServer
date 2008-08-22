class OrthomclGene < ActiveRecord::Base
  belongs_to :orthomcl_group
  has_many :orthomcl_gene_coding_regions
  has_many :coding_regions, :through => :orthomcl_gene_coding_regions
  has_one :orthomcl_gene_official_data
  
  named_scope :code, lambda { |three_letter_species_code| {
    :conditions => ['orthomcl_name like ?', "#{three_letter_species_code}%"]
  }}
  
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
  def compute_coding_region
    
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
      
      # Add the normally linked ones
      code = CodingRegion.find_by_name_or_alternate(name)
      if code
        return code
      else
        return nil
      end
      
      
      
      
    else # For non-official runs do nothing at the moment
      return nil
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
      real = official_split(og.orthomcl_name)[1]
      code = CodingRegion.find_by_name_or_alternate(real)
      
      if !code
        $stderr.puts "Failed to find coding region: #{real}"
        next
      end
      
      
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
end
