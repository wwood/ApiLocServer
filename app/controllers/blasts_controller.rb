require 'bio'

class BlastsController < ApplicationController
  def index
  end

  def blast
    @input = params[:sequence]
    @input ||= params[:id]

    # if there are any numbers in the given sequence, maybe it is from a
    # database. Do that as priority. If not, just use the regular one
    if @input.match /[01-9]/
      if code = CodingRegion.find_by_name_or_alternate(@input)
        logger.debug "Using coding region #{code} from #{code.species.name} to blast with"
        @input = code.aaseq
      end
    end

    # parse the name of the organism that is being blasted against
    @output = AminoAcidSequence.new.blast(@input, params[:taxa], params[:program], params[:database])
  end

  def blast_genbank
    @genbank_id = params[:seq]
    @genbank_id ||= params[:id]
    #identifiers are never lower case but NCBI is still case sensitive
    @genbank_id.upcase!

    unless @genbank_id
      flash[:error] = "No genbank identifier!"
      return
    end
    
    rets = Bio::NCBI::REST::efetch(@genbank_id, {:db => 'sequences', :rettype => 'fasta'})

    # Not sure what is returned exactly. I believe a string
    # is the most up to date.
    str = rets

    # make str = rets[0] unless rets is a String (this is old code?)
    unless rets.class == String
      unless rets.length == 1
        flash[:error] = "#{rets.length} sequences found! Expected 1."
        return
      end
      str = rets[0]
    end

    fasta = Bio::FastaFormat.new(str)
    @seq = fasta.seq
    @name = fasta.definition

    # if the sequence is nucleotide, then try to get the protein sequence
    # associated with it. I'm mostly only interested in the protein sequence
    # being correct.
    seq2 = Bio::Sequence.auto(@seq)
    if seq2.moltype == Bio::Sequence::NA and 
        !%w(blastn tblastx blastx).include?(params[:program]) #and
      # Commented out the line below because it was getting in the way of tblastn against the genome.
      # why was it there again? Can't remember.
      #  !%w(transcript genome).include?(params[:database])

      # found a nucleotide sequence. What is the protein sequence attached
      # to it?
      rets = Bio::NCBI::REST::efetch(@genbank_id, {:db => 'nucleotide', :rettype => 'gb'})
      raise unless rets.class == String #problems. If they occur I'll deal with it then
      gb = Bio::GenBank.new(rets)
      cds = gb.features.select{|f| f.feature == 'CDS'}
      # for pseudogenes, they have nucleotide but no amino acid sequence.
      # I get confused by 2 or more different CDSs.
      if cds.length > 0
        raise unless cds.length == 1 and cds[0].assoc['translation']
        @seq = cds[0].assoc['translation']
      end
    end

    @blast_output = AminoAcidSequence.new.blast(@seq, params[:taxa], params[:program], params[:database])
  end
end
