class Taxon < GUS
  set_table_name "sres.taxon"
  def primary_key 
    "taxon_id"
  end
  
  before_validation_on_create :set_defaults
  
  before_validation_on_update {modification_data = Date.today();}
end
