class BScript
  def localisation_publications_in_chronological_order
    pubs = []
    fails = 0
    
    Publication.all(:joins => {:expression_contexts => :localisation}).uniq.sort {|p1,p2|
      if p1.year.nil?
        -1
      elsif p2.year.nil?
        1
      else
        p1.year <=> p2.year
      end
    }.each do |pub|
      y = pub.year
      if y.nil? #ignore publications with improperly parsed years
        fails += 1
        next
      end
      
      pubs.push pub
    end
    
    $stderr.puts "Failed to year-ify #{fails} publications."
    return pubs
  end
  
  def localisation_and_publications_per_year_graphing
    already_localised = []
    
    year_publications = {}
    year_localisations = {}
    year_falciparum_localisations = {}
    year_toxo_localisations = {}
    year_falciparum_methods = {}
    year_toxo_methods = {}
    year_species_microscopy_types = {}
    
    # Get all the publications that have localisations in order
    localisation_publications_in_chronological_order.each do |pub|
      y = pub.year
      codes = CodingRegion.all(
      :joins => {
      :expression_contexts => [:localisation, :publication]
      },
      :conditions => {:publications => {:id => pub.id}}
      )
      found_novel = false
      
      
      codes.each do |i|
        unless already_localised.include?(i)
          found_novel = true
          already_localised.push i
          year_localisations[y] ||= 0
          year_localisations[y] += 1
          
          # What method was used?
          annotations = LocalisationAnnotation.all(
          :joins => [:coding_region, {:expression_contexts => :publication}],
          :conditions => {:publications => {:id => pub.id}, :coding_regions => {:id => i.id}}
          )
          biochemical_methods = annotations.reach.biochemical_method_classifications.flatten.uniq
          micro_types = annotations.reach.microscopy_type_classifications.flatten.uniq
          
          # counting falciparum proteins specifically          
          if i.species.name == Species::FALCIPARUM_NAME
            year_falciparum_localisations[y] ||= 0
            year_falciparum_localisations[y] += 1
            biochemical_methods.each do |meth|
              year_falciparum_methods[y] ||= {}
              year_falciparum_methods[y][meth] ||= 0
              year_falciparum_methods[y][meth] += 1
            end
            micro_types.each do |micro|
              species = 'falciparum'
              year_species_microscopy_types[y] ||= {}
              year_species_microscopy_types[y][species] ||= {}
              year_species_microscopy_types[y][species][micro] ||= 0
              year_species_microscopy_types[y][species][micro] += 1
            end
          end
          if i.species.name == Species::TOXOPLASMA_GONDII_NAME
            year_toxo_localisations[y] ||= 0
            year_toxo_localisations[y] += 1
            biochemical_methods.each do |meth|
              year_toxo_methods[y] ||= {}
              year_toxo_methods[y][meth] ||= 0
              year_toxo_methods[y][meth] += 1
            end
            micro_types.each do |micro|
              species = 'toxo'
              year_species_microscopy_types[y] ||= {}
              year_species_microscopy_types[y][species] ||= {}
              year_species_microscopy_types[y][species][micro] ||= 0
              year_species_microscopy_types[y][species][micro] += 1
            end
          end
        end
      end
      
      # Add a localisation if there has been a novel one found
      if found_novel
        year_publications[y] ||= 0
        year_publications[y] += 1
      end
    end
    
    biochems = ['epitope tag', 'fluorescent tag', 'antibody']
    puts ['year','localisations','publications','falciparum_locs','toxo_locs',biochems.collect{|b| "falciparum #{b}"},biochems.collect{|b| "toxo #{b}"},'falciparum light','falciparum EM', 'toxo light', 'toxo EM'].flatten.join("\t")
    keys = [year_localisations.keys, year_publications.keys].flatten.uniq.sort
    
    keys.each do |year|
      arr = [
      year,
      year_localisations[year],
      year_publications[year],
      year_falciparum_localisations[year],
      year_toxo_localisations[year],
      ]
      biochems.each do |meth|
        if year_falciparum_methods[year]
          arr.push year_falciparum_methods[year][meth]
        else
          arr.push 0
        end
      end
      biochems.each do |meth|
        if year_toxo_methods[year]
          arr.push year_toxo_methods[year][meth]
        else
          arr.push 0
        end
      end
      %w(falciparum toxo).each do |species|
        %w(light EM).each do |micro|
          if year_species_microscopy_types[year].nil? or 
            year_species_microscopy_types[year][species].nil? or 
            year_species_microscopy_types[year][species][micro].nil?
            arr.push 0
          else
            arr.push year_species_microscopy_types[year][species][micro]
          end
        end
      end
      
      puts arr.join("\t")
    end
  end
end