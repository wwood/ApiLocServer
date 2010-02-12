# A class for determining if a GenBank Identifier matches to
# a set of gene models

require 'bio'
require 'blast_helper'

class GenBankToGeneModelMapper
  # Attempt to determine if a GenBank translated sequence matches to a
  # single gene in a proteome
  def map(genbank_identifier, taxa, cutoff=1e-20)
    translateds = get_translated_sequences_from_genbank(genbank_identifier)
    
    raise unless translateds.length == 1
    translated = translateds[0]

    blast_output = BlastHelper.new.blast(translated, taxa, nil, 'protein', nil, {'-m' => 8})

    # now the tricky part. Determine if there is only a single match and
    # if it matches up correctly with the end of the protein.
    report = Bio::Blast::Report.new(blast_output)
    iter = report.iterations[0]
    if iter.hits.length == 0
      return "No blast hits!"
    elsif iter.hits.length == 1
      return blast_hit_description(iter.hits[0])
    else
      goods = iter.hits.select do |hit|
        hit.evalue < cutoff
      end
      return "No blast hits better than #{cutoff}" if goods.empty?
      return goods.collect { |good|
        blast_hit_description(good)
      }.join("\t")
    end
  end

  # string description of how good a hit is
  def blast_hit_description(blast_hit)
    if blast_hit.hsps.length == 1
      hsp = blast_hits.hsp[0]
      if hsp.query_from == 1 and hsp.hit_from == 1 and
          hsp.query_to == hsp.hit_to
        return "Exact match"
      elsif hsp.query_from == 1 and hsp.query_to < hsp. hsp.hit_to
        return "Inexact match, but GenBank fits inside"
      end
    end
  end

  # Return the translated sequence from a GenBank identifier as a
  # Bio::Seq object, with name and sequence
  def get_translated_sequences_from_genbank(genbank_id)
    # Set default email otherwise NCBI throws an error
    Bio::NCBI.default_email = 'b.woodcroft@pgrad.unimelb.edu.au'
    
    possibly_translated = Bio::NCBI::REST::efetch(genbank_id, {:db => 'sequences', :rettype => 'fasta'})

    # not sure if this is necessary / too onorous
    raise Exception, "found an array of hits from genbank id #{genbank_id}" if possibly_translated.kind_of?(Array)

    fastas = [Bio::FastaFormat.new(possibly_translated)]

    # convert to translated if not already translated
    translated_fastas = fastas.collect do |fasta|
      f_translated = Bio::Sequence.new('')
      f_translated.definition = fasta.definition
      
      # if the sequence is nucleotide, then try to get the protein sequence
      # associated with it. I'm mostly only interested in the protein sequence
      # being correct.
      seq2 = Bio::Sequence.auto(fasta.seq)
      if seq2.moltype == Bio::Sequence::NA
        # found a nucleotide sequence. What is the protein sequence attached
        # to it?
        rets = Bio::NCBI::REST::efetch(genbank_id, {:db => 'nucleotide', :rettype => 'gb'})
        raise unless rets.class == String #problems. If they occur I'll deal with it then
        gb = Bio::GenBank.new(rets)
        cds = gb.features.select{|f| f.feature == 'CDS'}
        # for pseudogenes, they have nucleotide but no amino acid sequence.
        # I get confused by 2 or more different CDSs.
        if cds.length > 0
          raise unless cds.length == 1 and cds[0].assoc['translation']
          f_translated.seq = cds[0].assoc['translation']
        end
      else
        # already have a protein sequence, so it is all good
        f_translated.seq = fasta.seq
      end
      f_translated
    end

    return translated_fastas
  end
end



# Run as script
if $0 == __FILE__
  require 'optparse'

  mapper = GenBankToGeneModelMapper.new

  options = ARGV.getopts("h") #s for summary, no args required
  if options['h'] or ARGV.length != 2
    $stderr.puts "Usage: genbank_to_gene_models.rb <genbank_id> <blast_database>"
    $stderr.puts "Where my.fasta is the name of the fasta file you want to analyse. Default output is all the sequences with their signal sequences cleaved."
    $stderr.puts "-s: summary: print a tab separated table indicating if the sequence had a signal peptide according to the HMM and NN results, respecitvely."
    exit 1
  end

  genbank_id = ARGV[0]
  taxa = ARGV[1]

  mapper.map(genbank_id, taxa)
  
end