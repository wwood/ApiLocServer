require 'signalp'

class SignalPCache < ActiveRecord::Base
  belongs_to :coding_region
  set_table_name 'signal_ps'
  
  # Given an amino acid sequence (just the letters), return whether it
  # has a signal sequence or not.
  # DEPRECATED
  def self.calculate_signal?(sequence)
    result = SignalSequence::SignalPWrapper.new.calculate(sequence)
    return result.signal?
  end
  
  # DEPRECATED
  def self.calculate_signal(sequence)
    return SignalSequence::SignalPWrapper.new.calculate(sequence)
  end
  
  # create from a SignalSequence::SignalPResult, given a coding region id
  # to boot.
  def self.create_from_result(coding_region_id, result)
    attrs = {:coding_region_id => coding_region_id}
    SignalSequence::SignalPResult.all_result_names.each do |name|
      attrs[name] = result.send(name)
    end
    SignalPCache.create!(attrs)
  end
  
  # Convert to a normal result object so methods can be
  # deferred there
  def to_signalp_result
    res = SignalSequence::SignalPResult.new
    SignalSequence::SignalPResult.all_result_names.each do |name|
      res.send("#{name}=", self.send(name))
    end
    return res
  end
  
  def cleave(sequence = nil)
    to_signalp_result.cleave(sequence.nil? ? coding_region.aaseq : sequence)
  end
  
  def signal?
    to_signalp_result.signal?
  end
  
  def classical_signal_sequence?
    to_signalp_result.classical_signal_sequence?
  end
end
