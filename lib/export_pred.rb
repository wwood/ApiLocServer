# 
# To change this template, choose Tools | Templates
# and open the template in the editor.
 
module Bio
  class ExportPred
    class Wrapper
      def calculate(sequence)
        Tempfile.open('exportpredpin') { |tempfilein|
          # Write a fasta to the tempfile
          tempfilein.puts '>wrapperSeq'
          tempfilein.puts "#{sequence.to_s}"
          tempfilein.close #required. Maybe because it doesn't flush otherwise?
      
          Tempfile.open('exportpredpout') {|out|
            result = system("exportpred --input=#{tempfilein.path} >#{out.path} 2>/dev/null")
        
            if !result
              raise Exception, "Running exportpredp program failed. See $? for details."
            end
            line = rio(out.path).read
            return Result.create_from_line(line)
          }
        }
      end
    end
    
    class Result
      @@all_result_names = [
        :predicted,
        :score
      ]
      @@all_result_names.each do |rn|
        attr_accessor rn
      end
     
      # Line may be
      def self.create_from_line(line)
        result = Result.new
        if !line or line == '' #possible bug that scores below 2.3 don't work
          result.predicted = false
          return result
        end
        
        # line is going to be something like
        # metoo	RLE	6.44141	[a-met:M][a-leader:AVSTYNNTRRNGLRYVLKRR][a-hydrophobic:TILSVFAVICMLSL][a-spacer:NLSIFENNNNNYGFHCNKRH][a-RLE:FKSLAEA][a-tail:SPEEHNNLRSHSTSDPKKNEEKSLSDEINKCDMKKYTAEEINEMINSSNEFINRNDMNIIFSYVHESEREKFKKVEENIFKFIQSIVETYKIPDEYKMRKFKFAHFEMQGYALKQEKFLLEYAFLSLNGKLCERKKFKEVLEYVKREWIEFRKSMFDVWKEKLASEFREHGEMLNQKRKLKQHELDRRAQREKMLEEHSRGIFAKGYLGEVESETIKKKTEHHENVNEDNVEKPKLQQHKVQPPKVQQQKVQPPKSQQQKVQPPKSQQQKVQPPKVQQQKVQPPKVQKPKLQNQKGQKQVSPKAKGNNQAKPTKGNKLKKN]
        splits = line.split("\t")
        raise Exception, "Badly parsed line: #{line}" if splits.length != 4
        result.predicted = true
        result.score = splits[2].to_f
        return result
      end
      
      def predicted?
        @predicted
      end
      alias_method :signal?, :predicted?
      
      def self.all_result_names
        @@all_result_names
      end
    end
  end
end