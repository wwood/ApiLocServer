class TaxonName < ActiveRecord::Base
  #  validates_presence_of :taxon_name_id
  before_validation_on_create :set_defaults
  
  set_table_name "sres.taxonname"
  set_sequence_name "taxonname_sq"
  set_primary_key "taxon_name_id"
  
  def set_defaults
    self.modification_date = Date.today();
    self.user_read = 1;
    self.user_write = 1;
    self.group_read = 1;
    self.group_write = 1;
    self.other_read = 1;
    self.other_write = 1;
    self.row_user_id = 1;
    self.row_group_id = 1;
    self.row_project_id = 1;
    self.row_alg_invocation_id = 1;
    self.taxon_name_id = 1;
  end
  
end
