class Gus < ActiveRecord::Base
  before_validation_on_create :set_defaults
  #TODO: make these much more sensible
  def set_defaults
    modification_date = Date.today();
    user_read = 1;
    user_write = 1;
    group_read = 1;
    group_write = 1;
    other_read = 1;
    other_write = 1;
    row_user_id = 1;
    row_group_id = 1;
    row_project_id = 1;
    row_alg_invocation_id = 1;
  end
  
  before_validation_on_update {modification_data = Date.today();}
end
