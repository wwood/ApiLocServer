class AddGoIndex < ActiveRecord::Migration
  INDEX_NAME = "go_term_idx_name";
  
  def self.up
    execute "create unique index #{INDEX_NAME} on go_terms (go_identifier)"
  end

  def self.down
    execute "drop index #{INDEX_NAME}"
  end
end
