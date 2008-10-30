require "rexml/document"

module Bio
  class NlsDb
    class Xml
      # initialize object with a new transmembrane domain filled with alpha-helical proteins
      def initialize(xml)
        @xml = REXML::Document.new(xml)
      end

      # Returns an array of NLSdb entries 
      def entries
        eees = []
        @xml.elements.each('LoadedSet/NLS_LOADER:NLS_LOADER') do |entry_xml|
          eees.push Entry.new(entry_xml)
        end
        return eees
      end
    end
    
    class Entry
      attr_reader :xml
      
      def initialize(xml)
        @xml = xml
      end

      def nls_db_id
        gimme('id').to_i
      end
      
      # To cover for all the rest of the attributes to make things easier
      # for me, the programmer
      def method_missing(method, *args, &block)
        if @xml.get_elements("NLS_LOADER:#{method}").length == 1
          return gimme(method)
        else
          super
        end
      end
      
      def origin
        gimme('origin').downcase
      end
      
      private
      def gimme(attribute_xpath)
        @xml.get_elements("NLS_LOADER:#{attribute_xpath}")[0].get_text.to_s
      end
    end
  end
end
