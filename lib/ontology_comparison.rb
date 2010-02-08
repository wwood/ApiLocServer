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

attr_accessor :common_ontologies, :disagreeing_ontologies

def agreement=(agreement)
raise Exception, "Unexpected agreement status '#{agreement}'" unless RECOGNIZED_STATUSES.include?(agreement)
end

end
