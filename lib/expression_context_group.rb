# To change this template, choose Tools | Templates
# and open the template in the editor.

class ExpressionContextGroup
  def initialize(expression_contexts)
    @expression_contexts = expression_contexts
  end

  # From @expression_contexts, return a list of
  # LocalisationsAndDevelopmentalStages objects
  # in a one-to-one relationship. Use stanzas
  # with the result of this method
  # take this list and condense it into something more concise.
  def to_localisations_and_developmental_stages
    @expression_contexts.collect do |ec|
      LocalisationsAndDevelopmentalStages.new(
      ec.localisation ?
      ec.localisation.name : [],
      ec.developmental_stage ?
      ec.developmental_stage.name : []
      )
    end
  end

  # Try to make this as concise as possible (ie least commas)
  # without losing or distorting the truth.
  def english
    return coalesce(to_localisations_and_developmental_stages)
  end

  # If the english representation of this expression context is
  # nucleus and cytosol during ring, cytosol during trophozoite,
  # then "nucleus and cytosol during ring" and "cytosol during trophozoite"
  # are the two stanzas (though they are not strings)
  def stanzas(locs_and_devs)
    # First, merge contexts where the loc is the same for each different
    # developmental stage
    locs_and_devs2 = []
    locs_and_devs.each do |landd|
    # are there any cousins?
      hits = locs_and_devs2.select do |l3|
        l3.localisation_ids == landd.localisation_ids
      end

      if hits.length == 1
        # if there is exactly one cousin all is ok
        hits[0].developmental_stage_ids = [
          hits[0].developmental_stage_ids,
          landd.developmental_stage_ids
        ].flatten
      elsif hits.length > 1
        # algorithmic error if there is more than one cousin
        raise Exception, "Unexpected to find more than one cousin with the same localisation!"
      else
      locs_and_devs2.push landd
      end
    end

    # Second, merge localisations where the developmental stages are different
    locs_and_devs3 = []
    locs_and_devs2.each do |landd|
    # are there any cousins?
      hits = locs_and_devs3.select do |l3|
        l3.developmental_stage_ids == landd.developmental_stage_ids
      end

      if hits.length == 1
        # if there is exactly one cousin all is ok
        hits[0].localisation_ids = [hits[0].localisation_ids, landd.localisation_ids].flatten
      elsif hits.length > 1
        # algorithmic error if there is more than one cousin
        raise Exception, "Unexpected to find more than one cousin with the same dev_stages!"
      else
      locs_and_devs3.push landd
      end
    end

    locs_and_devs3
  end

  def coalesce(locs_and_devs)
    stanzas(locs_and_devs).collect{|l|l.to_s}.join(', ')
  end

  alias_method :to_s, :english
end

# A generalised version of ExpressionContext for holding more

# than one context
class LocalisationsAndDevelopmentalStages
  attr_accessor :developmental_stage_ids, :localisation_ids
  def initialize(loc, dev)
    @developmental_stage_ids = [dev].flatten
    @localisation_ids = [loc].flatten
  end

  # sort so that positive locs are at the top
  def sort_by_positivity!
    @localisation_ids.sort!{ |a,b|
      if a.match(/^not /) and b.match(/^not /).nil?
      1
      elsif b.match(/^not /) and a.match(/^not /).nil?
      -1
      else
      a <=> b
      end
    }
    @developmental_stage_ids.sort!{ |a,b|
      if a.match(/^not /) and b.match(/^not /).nil?
      1
      elsif b.match(/^not /) and a.match(/^not /).nil?
      -1
      else
      a <=> b
      end
    }
  end

  #don't want ring and ring and ring
  def uniq!
    @localisation_ids.uniq!
    @developmental_stage_ids.uniq!
  end

  def to_s
    # prepare
    sort_by_positivity!
    uniq!

    if @localisation_ids.empty?
      if @developmental_stage_ids.empty?
        raise Exception, "No developmental stage or localisation found, so cannot give back a name."
      # #shouldn't ever happen, because otherwise there is no information
      else
        "during #{@developmental_stage_ids.join(' and ')}"
      end
    else
      if @developmental_stage_ids.empty?
        "#{@localisation_ids.join(' and ')}"
      else
        "#{@localisation_ids.join(' and ')} during #{@developmental_stage_ids.join(' and ')}"
      end
    end
  end
end
