require 'rubygems'
require 'array_pair'

# A class to represent how closely 2 genes are in their ontologies
class OntologyComparison
  COMPLETE_AGREEMENT = 'complete agreement'
  INCOMPLETE_AGREEMENT = 'incomplete agreement'
  DISAGREEMENT = 'disagreement'
  UNKNOWN_AGREEMENT = 'unknown'
  
  RECOGNIZED_STATUSES = [
  COMPLETE_AGREEMENT,
  INCOMPLETE_AGREEMENT,
  DISAGREEMENT,
  UNKNOWN_AGREEMENT
  ]
  
  # These localisation names must align with the gene ontology primary name
  # in lower case
  NUCLEUS_NAME = 'nucleus'
  CYTOSOL_NAME = 'cytosol'
  PLASTID_NAME = 'plastid'
  ENDOPLASMIC_RETICULUM_NAME = 'endoplasmic reticulum'
  
  RECOGNIZED_LOCATIONS = [
  NUCLEUS_NAME,
  PLASTID_NAME,
  'apoplast',
  'mitochondrion',
  ENDOPLASMIC_RETICULUM_NAME,
  'Golgi apparatus',
  CYTOSOL_NAME,
  'plasma membrane',
  'host cell', #parasite - specific
  'apical complex',
  'inner membrane complex',
  'cell wall',
  'lysosome',
  'peroxisome',
  'symbiont-containing vacuole',#parasitophorous vacuole is a synonym
  'endocytic vesicle',
  'glycosome',
  'flagellum',
  'cytoskeleton',
  'extracellular region part',
  'centrosome',
  'endocytic vesicle',
  ]
  
  attr_accessor :common_ontologies, :disagreeing_ontologies
  
  # Manually set agreement. Agreements can be calculated on the fly by
  # the agreement method, so potentially this method isn't needed.
  def agreement=(agreement)
    raise Exception, "Unexpected agreement status '#{agreement}'" unless RECOGNIZED_STATUSES.include?(agreement)
    @agreement = agreement
  end
  
  # If nucleus is common, and only 1 has cytoplasm, then that is complete agreement.
  # To fool later methods, remove the cytoplasm entry from the disagreeing ontologies
  def apply_nucleus_cytoplasm_modification
    return if @common_ontologies.nil? or @disagreeing_ontologies.nil?
    if @common_ontologies.include?(OntologyComparison::NUCLEUS_NAME) and
      @disagreeing_ontologies.include?(OntologyComparison::CYTOSOL_NAME)
      @disagreeing_ontologies.reject!{|o| o==OntologyComparison::CYTOSOL_NAME}
    end
  end
  
  # Class the agreements by using :common_ontologies, :disagreeing_ontologies
  # into one of COMPLETE_AGREEMENT, INCOMPLETE_AGREEMENT, DISAGREEMENT, UNKNOWN_AGREEMENT
  def agreement
    # return manually set agreement if that has been set
    return @agreement if @agreement
    
    if @common_ontologies.empty?
      if @disagreeing_ontologies.empty?
        OntologyComparison::UNKNOWN_AGREEMENT
      else
        OntologyComparison::DISAGREEMENT
      end
    elsif @disagreeing_ontologies.empty?
      OntologyComparison::COMPLETE_AGREEMENT
    else
      OntologyComparison::INCOMPLETE_AGREEMENT
    end
  end
  
  # 
  def agreement_of_pair(localisations_of_each_protein1, localisations_of_protein2)
    # First get the unknowns out of the way
    if localisations_of_each_protein1.nil? or localisations_of_protein2.nil? or
      localisations_of_each_protein1.empty? or localisations_of_protein2.empty?
      @common_ontologies = []
      @disagreeing_ontologies = []
    else
      commons = []
      disagreements = []
      all_organelles = [localisations_of_each_protein1,localisations_of_protein2].flatten
      all_organelles.each do |o|
        if localisations_of_each_protein1.include?(o) and localisations_of_protein2.include?(o)
          commons.push o
        elsif !localisations_of_each_protein1.include?(o) and !localisations_of_protein2.include?(o)
          raise Exception, "Programming problem"
        else
          disagreements.push o
        end
      end
      
      @common_ontologies = commons.uniq
      @disagreeing_ontologies = disagreements.uniq
      
      # Apply domain-specific information here
      # 1. If nucleus is common, and only 1 has cytoplasm, then that is complete agreement
      apply_nucleus_cytoplasm_modification
    end
    
    return agreement #agreement is calculated on the fly
  end
  
  # Given a array of arrays of localisation (an array of localisations for each protein),
  # return the total agreement of the group.
  def agreement_of_group(localisations_of_each_protein)
    all_pairwise_agreements = []
    localisations_of_each_protein.each_lower_triangular_matrix do |locs1, locs2|
      agree = agreement_of_pair(locs1, locs2)
      all_pairwise_agreements.push agree
    end
    return min_agreement(all_pairwise_agreements)
  end
  
  # order is best to worst, i.e. complete, incomplete, disagree
  def <=>(another)
    agree1 = agreement
    agree2 = another.agreement
    compare_agreement(agree1, agree2)
  end
  
  def compare_agreement(agreement1, agreement2)
    order = [COMPLETE_AGREEMENT, INCOMPLETE_AGREEMENT, DISAGREEMENT].to_hash
    unless order[agreement1] and order[agreement2]
      raise Exception, "Attempt to compare unexpected type of agreement '#{agreement1}' or '#{agreement2}'"
    end
    return -1*(order[agreement1] <=> order[agreement2])
  end
  
  def min_agreement(agreements)
    to_return = agreements.reject{|a| a==UNKNOWN_AGREEMENT}.min{|a,b| compare_agreement(a,b)}
    to_return ||= UNKNOWN_AGREEMENT
    to_return
  end
end
