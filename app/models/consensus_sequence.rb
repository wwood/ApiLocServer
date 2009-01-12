class ConsensusSequence < ActiveRecord::Base
  def regex
    /#{signal}/
  end
end