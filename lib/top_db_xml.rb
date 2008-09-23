require 'transmembrane'
require "rexml/document"


module Bio
  module TopDb
    class TopDbXml
      def initialize(xml)
        @xml = REXML::Document.new(xml)
      end
      
      def transmembrane_domains
        tmds = []
        confidence = nil
        @xml.elements.each('TOPDB/Topology/Reliability') do |rel|
          raise ParseException, "Too many reliability scored found" if confidence
          confidence = rel.text.to_i
        end
        
        @xml.elements.each('TOPDB/Topology/Regions/Region') do |region|
          if region.attributes['Loc'] == 'Membrane'
            t = Transmembrane::ConfidencedTransmembraneDomain.new
            t.start = region.attributes['Begin'].to_i
            t.stop = region.attributes['End'].to_i
            t.confidence = confidence
            tmds.push t
          end
        end
        
        return tmds
      end
    end
  end
end
