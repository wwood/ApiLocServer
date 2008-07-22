require 'signalp'

class SignalP < ActiveRecord::Base
  
  # Given an amino acid sequence (just the letters), return whether it
  # has a signal sequence or not.
  def self.calculate_signal?(sequence)
    result = SignalSequence::SignalPWrapper.new.calculate(sequence)
    return result.signal?
  end
  
  def self.calculate_signal(sequence)
    return SignalSequence::SignalPWrapper.new.calculate(sequence)
  end
end
