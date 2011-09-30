# To change this template, choose Tools | Templates
# and open the template in the editor.

module Bio
  class GeneAssociation
    # one line means one entry, excluding comments
    attr_accessor :entries

    ASPECT_HASH = {
      'F' => 'molecular_function',
      'C' => 'cellular_component',
      'P' => 'biological_process'
    }

    def initialize(io)
      @entries = []
      io.each_line do |current_line|
        unless current_line.match(/^\!/)
          entry = create_from_line(current_line)
          @entries << entry
        end
      end
    end

    def self.foreach(io)
      g = self.new('')
      io.each_line do |current_line|
        yield g.create_from_line(current_line)
      end
    end

    def create_from_line(gene_association_line)
      splits = gene_association_line.split("\t")
      
      # GAF 1.0 e.g.
      # SGD	S000000289	AAC3		GO:0005739	SGD_REF:S000117178|PMID:16823961	IDA		C	Mitochondrial inner membrane ADP/ATP translocator, exchanges cytosolic ADP for mitochondrially synthesized ATP	YBR085W|ANC3	gene	taxon:4932	20061212	SGD
      # GAF 2.0 has 17 columns
      raise Exception, "Could not parse gene association line: '#{gene_association_line}' - found #{splits.length} parts" unless splits.length == 15 || splits.length == 17

      entry = GeneOntologyEntry.new
      entry.primary_id = splits[1]
      entry.gene_name = splits[2]
      entry.go_identifier = splits[4]
      entry.evidence_code = splits[6]
      entry.aspect = ASPECT_HASH[splits[8]]
      entry.alternate_gene_ids = splits[10].split('|')
      return entry
    end
  end

  class GeneOntologyEntry
    attr_accessor :primary_id, :gene_name, :alternate_gene_ids, :go_identifier, :evidence_code, :aspect
  end

  # A class to handle gzipped gene association files which are piped to
  # grep and then stored in a temporary file.
  class GzipAndFilterGeneAssociation
    require 'rubygems'
    require 'zlib'
    require 'progressbar'
    def self.foreach(filename, grep_filter)
      tempfile = Tempfile.new('gene_association_gzip_grep')
      `zcat '#{filename}' |grep '#{grep_filter}' >#{tempfile.path}`
      tempfile.close
      progress = ProgressBar.new(File.basename(filename), `wc -l '#{tempfile.path}'`.to_i)

      GeneAssociation.foreach(File.open(tempfile.path,'r')) do |g|
        yield g
        progress.inc
      end
      progress.finish
    end
  end
end
