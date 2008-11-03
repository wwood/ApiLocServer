class GolgiNTerminalSignal < ConsensusSequence
  def florian_fill
    %w(.RR  	..RR  	...RR  	.R.R  	..R.R  	..R  	....R  	...K.R  	...RK).each do |signal|
      self.class.find_or_create_by_signal("^#{signal}")
    end
  end
end
