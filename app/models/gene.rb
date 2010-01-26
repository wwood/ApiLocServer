class Gene < ActiveRecord::Base
  #  validates_presence_of :scaffold_id
  validates_presence_of :name
  
  has_many :coding_regions, :dependent => :destroy
  has_many :gene_alternate_names, :dependent => :destroy
  belongs_to :scaffold
  
  # Rails doesn't handle these very well.
  has_many :gene_network_edge_firsts,
    :class_name => 'GeneNetworkEdge',
    :foreign_key => 'gene_id_first', 
    :dependent => :destroy
  has_many :gene_network_edge_seconds,
    :class_name => 'GeneNetworkEdge',
    :foreign_key => 'gene_id_second', 
    :dependent => :destroy

  UNANNOTATED_GENES_DUMMY_GENE_NAME = "Dummy gene for genes that don't exist"
    
  # create a dummy gene to satisfy validation
  def create_dummy(dummy_name)
    sp = Species.find_or_create_by_name dummy_name
    scaff = Scaffold.find_or_create_by_name_and_species_id dummy_name, sp.id
    gene = Gene.find_or_create_by_name_and_scaffold_id(dummy_name, scaff.id)
    return gene
  end

  def self.find_or_create_dummy(species_name)
    sp = Species.find_or_create_by_name species_name
    scaff = Scaffold.find_or_create_by_name_and_species_id species_name, sp.id
    return Gene.find_or_create_by_name_and_scaffold_id(species_name, scaff.id)
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
