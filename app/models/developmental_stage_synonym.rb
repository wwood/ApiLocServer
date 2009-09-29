class DevelopmentalStageSynonym < ActiveRecord::Base
  belongs_to :developmental_stage

  # Probably want to use this most of the time
  named_scope :species, lambda {|species_name|
    {
      :joins => {:developmental_stage => :species},
      :conditions => {:species => {:name => species_name}}
    }
  }

  # Probably want to use this most of the time
  named_scope :species_id, lambda {|species_id|
    {
      :joins => :developmental_stage,
      :conditions => {:developmental_stages => {:species_id => species_id}}
    }
  }
end
