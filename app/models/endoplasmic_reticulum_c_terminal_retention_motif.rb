class EndoplasmicReticulumCTerminalRetentionMotif < ConsensusSequence
  def fill
    %w(SDEL KDEL HDEL).each do |signal|
      self.class.find_or_create_by_signal("#{signal}$")
    end
  end
end
