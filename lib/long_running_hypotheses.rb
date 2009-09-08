# A class of methods that is intended to be run after every new database release,
# so that assumptions that are made in the past can be automatically
# invalidated. The idea is that we humans have already done the thinking,
# now it is time for the robots to agree or disagree forever more
class LongRunningHypotheses
  def hypothesize(description)
    unless block_given?
      raise Exception, "Hypothesis has no block: #{description}"
    end

    returned = yield
    if returned == false
      return advise_invalid_hypothesis(description)
      if returned.kind_of?(Array)
        unless returned.reject{|e| e == true}.empty?
          return advise_invalid_hypothesis(description)
        end
      else
        raise Exception, "malformed returned result: #{returned.inspect} from hypothesis #{description}"
      end
    end

    # sadly, everything is still A-OK, and nothing unexpected has happened.
    puts "Hypothesis validated: #{description}"
    return true
  end
  
  def advise_invalid_hypothesis(description)
    puts "Hypothesis invalid: #{description}"
    return false
  end
  
  def selenocysteine
    hypothesize "There is exactly 1 selenocysteine codon in falciparum" do
      sels = BScript2.new.selenocysteine_search
      sels.length == 1 and sels[0].string_id == 'MAL8P1.86'
    end

    Species.apicomplexan_names.collect do |name|
      hypothesize "There is exactly 1 selenocysteine codon in #{name} (#{CodingRegion.species(name).count(:joins => :amino_acid_sequence)})" do
        BScript2.new.selenocysteine_search(name).length == 1
      end
    end
  end
end
