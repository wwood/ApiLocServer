class LocalisationAnnotation < ActiveRecord::Base
  belongs_to :coding_region
  
  has_many :expression_contexts
  has_many :comments
  
  # Cherry and mCherry are different?
  FLUORESCENT_TAGS = %w(GFP RFP YFP CFP Cherry DsRed)
  EPITIOPE_TAGS = %w(myc HA FITC V5 TAP Ty FLAG his MBP GST strep).push('epitope tag')
  
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
    tags = [EPITIOPE_TAGS, FLUORESCENT_TAGS, 'antibod', 'ChIP'].flatten
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
  
  named_scope :chip, {
    :conditions => [
      'microscopy_type like ?', '%ChIP%'
    ]
  }
  
  # What kind of method was used to identify the molecule in the cell, broadly speaking?
  # e.g. direct antibody? GFP tag?
  def biochemical_method_classifications
    classes = []
    types = {
      'epitope tag' => EPITIOPE_TAGS,
      'fluorescent tag' => FLUORESCENT_TAGS,
    }
    
    return nil if microscopy_method.nil?
    splits = microscopy_method.downcase.split(', ')
    
    takens = {}
    types.each do |type, subtypes|
      subtypes.each do |m|
        splits.each_with_index do |s, i|
          if s.match(/#{m.downcase}/)
            classes.push type
            takens[i] ||= 0
            takens[i] += 1
          end
        end
      end
    end
    
    # Antibodies are special, because you can get things like 'antibody to GFP tag' which should count as a fluorescent tag
    splits.each_with_index do |s, i|
      # spelling mistakes are also being removed from the source data so they don't persist
      if takens[i].nil? and (s.match(/antibod/) or s.match(/anitbody/) or s.match(/antiody/)) 
        classes.push 'antibody'
        takens[i] ||= 0
        takens[i] += 1
      end
    end
    
    # takens count
    splits.each_with_index do |split, i|
      if takens[i].nil?
        $stderr.puts "WARNING: Did not assign #{i}/'#{split}' to any biochemical methods, from annotation #{id}, publication(s) #{expression_contexts.reach.publication.definition.join(", ")}"
      elsif takens[i] > 1
        $stderr.puts "WARNING: Assigned #{i}/'#{split}' to #{takens[i]} different biochemical methods, from annotation #{id}, publication(s) #{expression_contexts.reach.publication.definition.join(", ")}"
      end
    end
    
    return classes
  end
  
  def microscopy_type_classifications
    if microscopy_type.nil?
      $stderr.puts "No microscopy type recorded for annotation #{id}, publication(s) #{expression_contexts.reach.publication.definition.join(", ")}"
      return []
    end
    
    classes = []
    microscopy_type.downcase.split(', ').each do |m|
      if m.match(/light/)
        classes.push 'light'
      elsif m.match(/em/) or m.match(/electron/)
        classes.push 'EM'
      elsif m.match(/chip/)
        classes.push 'EM'
      else
        $stderr.puts "Unable to classify microscopy type `#{m}'"
      end
    end
    return classes
  end
end
