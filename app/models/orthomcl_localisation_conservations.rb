# A class to represent whether localisation in the current group has a conserved
# localisation or not.
class OrthomclLocalisationConservations < ActiveRecord::Base
  belongs_to :orthomcl_group

  SENSIBLE_CONSREVATIONS = %w(
    complex
    unknown
    conserved).push('not conserved')

  validates_each :conservation do |record, attr, value|
    record.errors.add attr, 'invalid evidence code' unless SENSIBLE_CONSERVATTIONS.include?(value)
  end
end
