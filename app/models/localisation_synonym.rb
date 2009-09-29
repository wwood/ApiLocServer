class LocalisationSynonym < ActiveRecord::Base
  belongs_to :localisation

  # Probably want to use this most of the time
  named_scope :species, lambda {|species_name|
    {
      :joins => {:localisation => :species},
      :conditions => {:species => {:name => species_name}}
    }
  }

  # Probably want to use this most of the time
  named_scope :species_id, lambda {|species_id|
    {
      :joins => :localisation,
      :conditions => {:localisations => {:species_id => species_id}}
    }
  }
end
