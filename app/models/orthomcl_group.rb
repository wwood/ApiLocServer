class OrthomclGroup < ActiveRecord::Base
  has_many :orthomcl_genes
  belongs_to :orthomcl_run
  
  named_scope :overlapping do |*species_array|  
    if species_array.length != 2 or true
      raise Exception, "Unhandled number of orthomcl species"
      fd
    end
    {}
  end
  
  named_scope :run, lambda {|run_name|
    {
      :joins => :orthomcl_run,
      :conditions => ['orthomcl_runs.name = ?', run_name]
    }
  }
  
  named_scope :official, {:joins => :orthomcl_run, :conditions => {:orthomcl_runs => {:name => OrthomclRun.official_run_v2_name}}}
  
  # Find all the groups that have one or more genes from each of multiple species. 
  # For instance OrthomclGroup.all_overlapping_groups(['dme','cel') will find all the
  # groups that have genes from both drosophila melanogaster (dme) and elegans (cme).
  def self.all_overlapping_groups(orthomcl_species_identifiers)
    # OrthomclGroup.find_by_sql("select g.id, cel.orthomcl_name,
    #dme.orthomcl_name, g.orthomcl_name from orthomcl_groups g,
    #orthomcl_genes cel, orthomcl_genes dme where
    #cel.orthomcl_group_id=g.id and dme.orthomcl_group_id=g.id and
    #cel.orthomcl_name like 'cel%' and dme.orthomcl_name like
    #'dme%').orthomcl_genes )
    
    # add the tables to select from
    sql = 'select distinct(g.id) from orthomcl_groups g, orthomcl_runs run'
    orthomcl_species_identifiers.each do |spid|
      sql += ", orthomcl_genes #{spid}"
    end
    
    # add the conditions, for the run, the join, and the name like
    sql += " where run.name = '#{OrthomclRun.official_run_v2_name}' and g.orthomcl_run_id=run.id"
    orthomcl_species_identifiers.each do |spid|
      sql += " and #{spid}.orthomcl_name like '#{spid}%' and #{spid}.orthomcl_group_id = g.id"
    end
    
    return self.find_by_sql(sql)
  end
  
  # return true iff this group contains 1 orthomcl_gene of each from
  # each species in this group.
  def single_members_by_codes(orthomcl_three_letter_codes)
    orthomcl_three_letter_codes.each do |three|
      return false if orthomcl_genes.code(three).count != 1
    end
    return true
  end
end
