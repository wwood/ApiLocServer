# A wrapper around the selected ID mapping file available
# from ftp://ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/idmapping/
#
# According to the README file there, the file contains these columns:
#1. UniProtKB-AC
#2. UniProtKB-ID
#3. GeneID (EntrezGene)
#4. RefSeq
#5. GI
#6. PDB
#7. GO
#8. IPI
#9. UniRef100
#10. UniRef90
#11. UniRef50
#12. UniParc
#13. PIR
#14. NCBI-taxon
#15. MIM
#16. UniGene
#17. PubMed
#18. EMBL
#19. EMBL-CDS
#20. Ensembl
#21. Ensembl_TRS
#22. Ensembl_PRO

module Bio
  class UniProtIDMappingSelected
    def initialize(gzfilename = '/home/ben/phd/data/UniProt/current_release/idmapping/idmapping_selected.tab.gz')
      @gzfilename = gzfilename
    end

    def find_by_ensembl_protein_id(ensembl_id)
      lines = `gunzip -c #{@gzfilename} |grep #{ensembl_id}`
      return create_mapped_from_lines(lines, ensembl_id)
    end
    
    def create_mapped_from_lines(lines, search_id)
      split = lines.split("\n")
      raise Exception, "Unexpected number of lines found #{lines.length} using '#{search_id}' to grep" unless split.length == 1
      return create_mapped_line(split[0])
    end

    def create_mapped_line(line)
      mapped = UniProtIDMappedTerms.new
      mapped.line = line
      splits = line.split("\t")

      i = 0
      mapped.uniprotkb_ac = splits[i]; i+=1
      mapped.uniprotkb_id = splits[i]; i+=1
      mapped.geneid = splits[i]; i+=1
      mapped.refseq = splits[i]; i+=1
      mapped.gi = splits[i]; i+=1
      mapped.pdb = splits[i]; i+=1
      mapped.go = splits[i]; i+=1
      mapped.ipi = splits[i]; i+=1
      mapped.uniref100 = splits[i]; i+=1
      mapped.uniref90 = splits[i]; i+=1
      mapped.uniref50 = splits[i]; i+=1
      mapped.uniparc = splits[i]; i+=1
      mapped.pir = splits[i]; i+=1
      mapped.ncbi_taxon = splits[i]; i+=1
      mapped.mim = splits[i]; i+=1
      mapped.unigene = splits[i]; i+=1
      mapped.pubmed = splits[i]; i+=1
      mapped.embl = splits[i]; i+=1
      mapped.embl_cds = splits[i]; i+=1
      mapped.ensembl = splits[i]; i+=1
      mapped.ensembl_trs = splits[i]; i+=1
      mapped.ensembl_pro = splits[i].split('; ')
      
      return mapped
    end
  end

  class UniProtIDMappedTerms
    attr_accessor :line

    attr_accessor :uniprotkb_ac
    attr_accessor :uniprotkb_id
    attr_accessor :geneid
    attr_accessor :refseq
    attr_accessor :gi
    attr_accessor :pdb
    attr_accessor :go
    attr_accessor :ipi
    attr_accessor :uniref100
    attr_accessor :uniref90
    attr_accessor :uniref50
    attr_accessor :uniparc
    attr_accessor :pir
    attr_accessor :ncbi_taxon
    attr_accessor :mim
    attr_accessor :unigene
    attr_accessor :pubmed
    attr_accessor :embl
    attr_accessor :embl_cds
    attr_accessor :ensembl
    attr_accessor :ensembl_trs
    attr_accessor :ensembl_pro
  end
end