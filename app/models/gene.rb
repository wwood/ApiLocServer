class Gene < ActiveRecord::Base
  #  validates_presence_of :scaffold_id
  validates_presence_of :name
  
  has_many :coding_regions, :dependent => :destroy
  has_many :gene_alternate_names, :dependent => :destroy
  belongs_to :scaffold
  
  has_many :drosophila_allele_genes
  
  # create a dummy gene to satisfy validation
  def create_dummy(dummy_name)
    sp = Species.find_or_create_by_name dummy_name
    scaff = Scaffold.find_or_create_by_name_and_species_id dummy_name, sp.id
    gene = Gene.find_or_create_by_name_and_scaffold_id dummy_name, scaff.id
    return gene
  end
  
  
  # Return the gene associated with the name. The string_id
  # can be either a real id, or an alternate id.
  def self.find_by_name_or_alternate(name)
    simple = Gene.find_by_name name
    if simple
      return simple
    else
      alt = GeneAlternateName.find_by_name name
      if alt
        return alt.gene
      else
        return nil
      end
    end
  end
  
  def self.find_by_name_or_alternate_and_organism(name, organism_common_name)
    simple = Gene.find(:first,
      :include => {:scaffold => :species},
      :conditions => ["species.name=? and genes.name=?", 
        organism_common_name, name
      ]
    )
    if simple
      return simple
    else
      alt = GeneAlternateName.find(:first,
        :include => {:gene => {:scaffold => :species}},
        :conditions => ["species.name= ? and gene_alternate_names.name= ?", 
          organism_common_name, name
        ]
      )
      if alt
        return alt.gene
      else
        return nil
      end
    end    
  end

end
