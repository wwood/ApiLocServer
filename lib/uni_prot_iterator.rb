require 'bio'
require 'tempfile'
require 'progressbar'

# An iterator for a bunch of UniProt entries
module Bio
  class UniProtIterator
    def self.foreach(gzfilename, regex)
      current_uniprot_string = ''
    
      temp = Tempfile.new("uniprot_iterator")
      # ungzip the file and pipe to a tempfile only those entries that match the regex
      `zcat '#{gzfilename}' |egrep '^(AC|//|#{regex})' >#{temp.path}`

      temp.close #closes the file but doesn't unlink it until the variable is finalised ie. the method is finished

      progress = ProgressBar.new(File.basename(gzfilename), `grep '^//' '#{temp.path}' |wc -l`.to_i)
      File.foreach(temp.path) do |line|
        if line == "//\n"
          progress.inc

          u = Bio::UniProt.new(current_uniprot_string)

          yield u

          current_uniprot_string = ''
        else
          current_uniprot_string += line
        end
      end
      progress.finish
    end
  end
end
