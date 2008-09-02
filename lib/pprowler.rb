require 'csv'

module Bio
  class Pprowler
    class Report
      attr_accessor :predictions
      
      def parse(pprowler_output)
        pprowler_output.split("\n").each do |line|
          row = line.split(/\s+/)
          raise Exception, "Couldn't handle line #{row.inspect}" if row.length != 7
          
          r = Result.new
          r.sp = row[3].to_f
          r.mtp = row[4].to_f
          r.other = row[5].to_f
          
          if @predictions.nil?
            @predictions = {}
          end
          @predictions[row[0]] = r
        end
      end
    end
    
    class Result
      # SP, mTP, other
      attr_accessor :sp, :mtp, :other
      # binary true/false prediction output by PATS
      attr_accessor :prediction
    end
  end
end
