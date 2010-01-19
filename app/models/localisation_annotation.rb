class LocalisationAnnotation < ActiveRecord::Base
  belongs_to :coding_region

  has_many :expression_contexts
  has_many :comments

  # Cherry and mCherry are different?
  FLUORESCENT_TAGS = %w(GFP RFP YFP CFP Cherry DsRed DsRED)
  EPITIOPE_TAGS = %w(myc HA FITC V5 TAP).push('epitope tag')

  named_scope :antibody, {
    :conditions => ['microscopy_method like ?',
      '%antibod%'
    ]
  }
  def self.fluorescent_conditions
    [
      FLUORESCENT_TAGS.collect {|f|
        'microscopy_method like ?'
      }.join(' or '),
      FLUORESCENT_TAGS.collect do |f|
        "%#{f}%"
      end
    ].flatten
  end
  
  named_scope :fluorescent, {
    :conditions => fluorescent_conditions
  }
  
  def self.epitope_tag_conditions
    [
      EPITIOPE_TAGS.collect {|f|
        'microscopy_method like ?'
      }.join(' or '),
      EPITIOPE_TAGS.collect do |f|
        "%#{f}%"
      end
    ].flatten
  end
  named_scope :epitope_tag, {
    :conditions => epitope_tag_conditions
  }

  named_scope :light, {
    :conditions => ['microscopy_type like ? or microscopy_type like ?',
      '%light%', '%Light%'
    ]
  }
  named_scope :em, {
    :conditions => ['microscopy_type like ? or microscopy_type like ?',
      '%EM%', '%Electron%'
    ]
  }

  def self.unclassified_method_conditions
    tags = [EPITIOPE_TAGS, FLUORESCENT_TAGS, 'antibod'].flatten
    [
      tags.collect {|f|
        'microscopy_method not like ?'
      }.join(' and '),
      tags.collect do |f|
        "%#{f}%"
      end
    ].flatten
  end
  named_scope :unclassified_method, {
    :conditions => unclassified_method_conditions
  }

  # names of microscopy types hashed to the named scopes that are used to search
  # for them
  POPULAR_MICROSCOPY_TYPE_NAME_SCOPE = {
    'Light microscopy using an antibody to protein or part thereof' => [:light,:antibody],
    'Light microscopy using an antibody to an epitope tag' => [:light,:epitope_tag],
    'Light microscopy using a fluorescent tag' => [:fluorescent],
    'Electron microscopy (EM)' => [:em],
    'Chromatin Immunoprecipitation (ChIP)' => [:chip]
  }
end
