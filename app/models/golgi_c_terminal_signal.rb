class GolgiCTerminalSignal < ConsensusSequence
  def florian_fill
    %w(KK..  	R.K..  	K.K..  	K.R..).each do |signal|
      self.class.find_or_create_by_signal("#{signal}$")
    end
  end
end
