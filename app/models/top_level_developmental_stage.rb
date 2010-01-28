class TopLevelDevelopmentalStage < ActiveRecord::Base
  has_many :developmental_stage_top_level_developmental_stages, :dependent => :destroy
  has_many :developmental_stages, :through => :developmental_stage_top_level_developmental_stages

  named_scope :positive, {
    :conditions => ['top_level_developmental_stages.name not like ?', 'not %']
  }
end
