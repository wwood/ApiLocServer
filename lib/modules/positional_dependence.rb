# Methods (unsupervised?) looking to work out if there is positional
# dependence within protein classes
class BScript
  def signalp_along_chromosomes(species_name=Species::FALCIPARUM_NAME)
    Species.find_by_name(species_name).scaffolds.each do |scaffold|
      print scaffold.name
      code = scaffold.downstreamest_coding_region
      while code != nil
        sig = code.signalp_however
        if sig
          print ","
          print code.signalp_however.signal? ? 1 : 0
        end
        code = code.next_coding_region
      end
      puts
    end
  end
end
