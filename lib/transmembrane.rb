# a simple class to represent a TMD

module Transmembrane

  class TransmembraneProtein
    attr_accessor :transmembrane_domains, :name
  
    def initialize
      # default no domains to empty array not nil
      @transmembrane_domains = []
    end
  
    def push(transmembrane_domain)
      @transmembrane_domains.push transmembrane_domain
    end
  
    def average_length
      @transmembrane_domains.inject(0){|sum,cur| sum+cur.length}.to_f/@transmembrane_domains.length.to_f
    end
  
    def minimum_length
      @transmembrane_domains.min.length
    end
  
    def maximum_length
      @transmembrane_domains.max.length
    end
  
    def has_domain?
      !@transmembrane_domains.empty?
    end
  end
  
  class OrientedTransmembraneDomainProtein<TransmembraneProtein
    def transmembrane_type_1?
      @transmembrane_domains and @transmembrane_domains.length == 1 and @transmembrane_domains[0].orientation == OrientedTransmembraneDomain::OUTSIDE_IN
    end
    
    def transmembrane_type_2?
      @transmembrane_domains and @transmembrane_domains.length == 1 and @transmembrane_domains[0].orientation == OrientedTransmembraneDomain::INSIDE_OUT
    end
    
    def transmembrane_type
      if transmembrane_type_1?
        return 'I'
      elsif transmembrane_type_2?
        return 'II'
      else
        return 'Unknown'
      end
    end
  end

  class TransmembraneDomainDefinition
    attr_accessor :start, :stop
  
    def length
      @stop-@start+1
    end
  
    def <=>(other)
      length <=> other.length
    end
    
    def ==(other)
      start == other.start and
        stop == other.stop
    end
    
    def sequence(protein_sequence_string, nterm_offset=0, cterm_offset=0)
      protein_sequence_string[(start+nterm_offset-1)..(stop+cterm_offset-1)]
    end
  end
  
  class ConfidencedTransmembraneDomain<TransmembraneDomainDefinition
    attr_accessor :confidence
    
    def <=>(other)
      return start<=>other.start if start<=>other.start
      return stop<=>other.start if stop<=>other.stop
      return confidence <=> other.confidence
    end
    
    def ==(other)
      start == other.start and
        stop == other.stop and
        confidence == other.confidence
    end
  end
  
  class OrientedTransmembraneDomain<TransmembraneDomainDefinition
    # The orientation can either be inside out (like a type II transmembrane domain protein)
    INSIDE_OUT = 'inside_out'
    # Or outside in, like a type I transmembrane domain protein)
    OUTSIDE_IN = 'outside_in'
    
    attr_accessor :orientation
  end
end