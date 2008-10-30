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
        if ['annotation', 'medlineID','signal','origin'].include?(method.to_s)
          els = @xml.get_elements("NLS_LOADER:#{method.to_s}")
          if els.length == 1 and !els[0].nil? #normal
            return gimme(method)
          elsif els.length > 1
            raise Exception, "Bad Parsing!"
          else
            return nil #that's ok
          end
        else
          super
        end
      end
      
      def origin
        gimme('origin').capitalize!
      end
      
      def medlineID
        m = gimme('medlineID')
        m.nil? ? nil : m.to_i
      end
      
      private
      def gimme(attribute_xpath)
        el = @xml.get_elements("NLS_LOADER:#{attribute_xpath}")[0]
        el ? el.get_text.to_s : nil
      end
    end
  end
end
