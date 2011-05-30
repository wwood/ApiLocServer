require 'bio'
require 'bio-tm_hmm'
require "rexml/document"

module Bio
  class PdbTm
    class Xml
      # initialize object with a new transmembrane domain filled with alpha-helical proteins
      def initialize(xml)
        @xml = REXML::Document.new(xml)
      end
      
      # Returns an array of PdbTm objects, and from there the transmembranes can be 
      def entries
        eees = []
        @xml.elements.each('PDBTM/pdbtm') do |pdbtm|
          eees.push Entry.new(pdbtm)
        end
        return eees
      end
    end
    
    
    class Entry
      attr_reader :xml
      
      def initialize(xml)
        @xml = xml
      end
      
      # Each PDB TM entry can have 1 or more chains, each that may or may not contain a 
      # transmembrane domain. This method returns an array of transmembranes so that it can be
      # from all of the chains
      def transmembrane_domains
        tmds = []
        @xml.elements.each('CHAIN') do |rel|
#          p rel.to_s
          rel.elements.each('REGION') do |region|
            if region.attributes['type'] == 'H'
#              p "found region: #{region}"
              t = Bio::Transmembrane::TransmembraneDomainDefinition.new
              t.start = region.attributes['seq_beg'].to_i
              t.stop = region.attributes['seq_end'].to_i
              tmds.push t
            end
          end
        end
        
        return tmds
      end
      
      def pdb_id
        @xml.attributes['ID']
      end
    end
  end
end
