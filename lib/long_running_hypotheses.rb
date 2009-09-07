# A class of methods that is intended to be run after every new database release,
# so that assumptions that are made in the past can be automatically
# invalidated. The idea is that we humans have already done the thinking,
# now it is time for the robots to agree or disagree forever more
class LongRunningHypotheses
  def hypothesize(description)
    unless block_given?
      raise Exception, "Hypothesis has no block: #{description}"
    end

    unless yield
      puts "Hypothesis invalid: #{description}"
      return false
    end
    return true
  end
  
  def falciparum
    hypothesize "There is only 1 selenocysteine codon in falciparum" do
      sels = BScript2.new.selenocysteine_search
      sels.length == 1 and sels[0].string_id == 'MAL8P1.86'
    end
  end
end
