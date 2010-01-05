class OrthomclGroup < ActiveRecord::Base
  has_many :orthomcl_gene_orthomcl_group_orthomcl_runs, :dependent => :destroy
  has_many :orthomcl_genes, :through => :orthomcl_gene_orthomcl_group_orthomcl_runs
  has_one :orthomcl_run, :through => :orthomcl_gene_orthomcl_group_orthomcl_runs
  has_one :orthomcl_localisation_onservations
  
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
  
  named_scope :official, {:joins => :orthomcl_run, :conditions => ['orthomcl_runs.name = ?', OrthomclRun::ORTHOMCL_OFFICIAL_NEWEST_NAME]}
  
  # Find all the groups that have one or more genes from each of multiple species. 
  # For instance OrthomclGroup.all_overlapping_groups(['dme','cel') will find all the
  # groups that have genes from both drosophila melanogaster (dme) and elegans (cme).
  def self.all_overlapping_groups(orthomcl_species_identifiers)
    return OrthomclGroup.official.all(:select => 'distinct(orthomcl_groups.id)') if orthomcl_species_identifiers.empty?
    
    # add the tables to select from
    sql = 'select distinct(g.id) from orthomcl_groups g, orthomcl_runs run'
    orthomcl_species_identifiers.each do |spid|
      sql += ", orthomcl_genes #{spid}, orthomcl_gene_orthomcl_group_orthomcl_runs ogogor_#{spid}"
    end
    
    # add the conditions, for the run, the join, and the name like
    sql += " where run.name = '#{OrthomclRun::ORTHOMCL_OFFICIAL_NEWEST_NAME}'"
    orthomcl_species_identifiers.each do |spid|
      ogogor_table = "ogogor_#{spid}"
      sql += " and #{spid}.orthomcl_name like '#{spid}%'"+
        " and #{ogogor_table}.orthomcl_group_id = g.id"+
        " and #{ogogor_table}.orthomcl_run_id=run.id"+
        " and #{ogogor_table}.orthomcl_gene_id=#{spid}.id"
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
