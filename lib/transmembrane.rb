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

  class TransmembraneDomain
    attr_accessor :start, :stop
  
    def length
      @stop-@start+1
    end
  
    def <=>(other)
      length <=> other.length
    end
  end
end