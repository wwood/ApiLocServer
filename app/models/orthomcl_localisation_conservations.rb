# A class to represent whether localisation in the current group has a conserved
# localisation or not.
class OrthomclLocalisationConservations < ActiveRecord::Base
  belongs_to :orthomcl_group

  SENSIBLE_CONSERVATIONS = %w(
    complex
    unknown
    conserved).push('not conserved')

  validates_each :conservation do |record, attr, value|
    record.errors.add attr, 'invalid evidence code' unless SENSIBLE_CONSERVATIONS.include?(value)
  end

  # When manually mapping, I use various one letter
  # abbreviations, but this model only accepts full words.
  # This method maps from the one letter to the full words
  def self.single_letter_to_full_name(single_letter)
   {
      '-' => 'unknown',
      'c' => 'complex',
      'y' => 'conserved',
      'n' => 'not conserved'
    }[single_letter]
  end
end
