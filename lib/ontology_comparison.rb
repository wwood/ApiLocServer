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
  
  RECOGNIZED_LOCATIONS = [
  NUCLEUS_NAME,
  PLASTID_NAME,
  'apoplast',
  'mitochondrion',
  'endoplasmic reticulum',
  'Golgi apparatus',
  CYTOSOL_NAME,
  'plasma membrane',
  'host cell', #apicomplexan - specific
  'apical complex',
  'inner membrane complex',
  'cell wall',
  'lysosome',
  'peroxisome',
  'parasitophorous vacuole'
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
end
