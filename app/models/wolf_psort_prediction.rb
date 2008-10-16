class WolfPsortPrediction < ActiveRecord::Base
  belongs_to :coding_region
  
  def self.cache_falciparum_predictions
    CodingRegion.falciparum.all(:joins => :amino_acid_sequence).each do |code|
      p code.id
      code.cache_wolf_psort_predictions
    end
  end
end
