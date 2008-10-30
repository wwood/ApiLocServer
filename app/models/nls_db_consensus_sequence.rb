class NlsDbConsensusSequence < ActiveRecord::Base
  def upload_from_xml(filename="#{Script::DATA_DIR}/databases/NLSdb/nlsdb.generic.xml")
    require 'nls_db'
    
    Bio::NlsDb::Xml.new(File.open(filename).read).entries.each do |e|
      # nls_db_id:integer type:string signal:string annotation:string pubmed_id:integer
      o = NlsDbConsensusSequence.find_or_create_by_nls_db_id_and_type_and_signal_and_annotation_and_pubmed_id(
        e.nls_db_id,
        "#{e.origin}NlsDbConsensusSequence",
        e.signal,
        e.annotation,
        e.medlineID
      )
    end
  end
  
  def regexp
    /#{signal}/
  end
end
