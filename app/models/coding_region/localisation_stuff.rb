class CodingRegion < ActiveRecord::Base
  
  def agreement_with_top_level_localisation(top_level_localisation, parameter_options={})
    raise if parameter_options[:by_literature] #deprecated, use expression_context_evidence => :second_class_citizen_expression_contexts instead
    
    options = {
    :expression_context_evidence_class => nil,
    }.merge(parameter_options)
    
    known_tops = nil
    expressed_locs = nil
    if options[:expression_context_evidence_class]
      known_tops = tops_by_evidence(options[:expression_context_evidence_class])
      expressed_locs = expressed_localisations_by_evidence(options[:expression_context_evidence_class])
    else
      known_tops = topsa
      expressed_locs = expressed_localisations
    end
    
    raise Exception, 
      "Not a TopLevelLocalisation: #{top_level_localisation.inspect}" unless
    top_level_localisation.kind_of?(TopLevelLocalisation)
    
    if known_tops.include?(top_level_localisation)
      if known_tops.length == 1
        # if top_levels agree, but there is some rubbish left over?
        if expressed_locs.select {|l|
            l.apiloc_top_level_localisation.nil?
          }.length > 0
          return "agree but not exclusively"
        else
          return "agree exclusively"
        end
      else
        # there is another top level localisation, so we aren't exclusive,
        # except if the others are negative
        if known_tops.include?(top_level_localisation.negation)
          return "conflicting"
        elsif known_tops.reject{|t| t.negative?}.length > 1
          return "agree but not exclusively"
        else
          return "agree exclusively"
        end
      end
    else
      # so there is no agreement
      if known_tops.include?(top_level_localisation.negation)
        return "disagree specifically"
      else
        if expressed_locs.length == 0
          return "not localised"
        else
          return "disagree but not specifically"
        end
      end
    end
  end
  
  # like CodingRegion#agreement_with_top_level_localisation, except only return
  # these strings: agree, disagree, conflict, "" (for not localised)
  def agreement_with_top_level_localisation_simple(top_level_localisation, parameter_options={})
    raise if parameter_options[:by_literature] #deprecated, use expression_context_evidence => :second_class_citizen_expression_contexts instead
    options = {
    :expression_context_evidence_class => nil,
    }.merge(parameter_options)
    
    # Get the overall agreement
    agreement = nil
    if options[:expression_context_evidence_class]
      agreement = agreement_with_top_level_localisation(top_level_localisation, :expression_context_evidence_class => options[:expression_context_evidence_class])
    else
      agreement = agreement_with_top_level_localisation(top_level_localisation)
    end
    
    if [
        "agree but not exclusively",
        "agree exclusively"
      ].include? agreement
      return 'agree'
    elsif [
        "disagree specifically",
        "disagree but not specifically"
      ].include? agreement
      return 'disagree'
    elsif agreement == 'conflicting'
      return 'conflict'
    elsif agreement == 'not localised'
      return nil
    else
      raise #bad programming has happened
    end
  end
  
  def apilocalisations
    if curates.empty?
      return topsap
    else
      return curates
    end
  end
  
  def apiloc_url
    "http://apiloc.biochem.unimelb.edu.au/apiloc/apiloc/gene/#{species.name}/#{string_id}"
  end
end