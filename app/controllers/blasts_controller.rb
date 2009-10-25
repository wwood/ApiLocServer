require 'bio'
require 'gen_bank_to_gene_model_mapper'

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
        logger.debug "Using coding region #{code} from #{code.species.name} to blast with. It has amino acid sequence #{code.aaseq}"
        @input = code.aaseq
      end
    end

    logger.debug("Blasting with sequence: #{@input}")

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
    
    translateds = GenBankToGeneModelMapper.new.get_translated_sequences_from_genbank(
      @genbank_id
    )

    # make str = rets[0] unless rets is a String (this is old code?)
    unless translateds.length == 1
      flash[:error] = "#{translateds.length} sequences found! Expected 1."
      return
    end
    translated = translateds[0]

    @seq = translated.seq
    @name = translated.definition

    logger.debug("Blasting with #{translated}")

    @blast_output = AminoAcidSequence.new.blast(@seq, params[:taxa], params[:program], params[:database])
  end
end
