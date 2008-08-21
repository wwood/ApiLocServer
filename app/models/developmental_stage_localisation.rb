class DevelopmentalStageLocalisation < ActiveRecord::Base
  belongs_to :developmental_stage
  belongs_to :localisation
  
  # comparison operator, created for testing
  def <=>(dsl)
    one = developmental_stage_id <=> dsl.developmental_stage_id
    return one if one
    two = localisation_id <=> dsl.localisation_id
    return two
  end
end
