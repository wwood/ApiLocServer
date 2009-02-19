class ChangeCodeGoConstraints < ActiveRecord::Migration
  def self.up
    remove_index :coding_region_go_terms,
      [:coding_region_id, :go_term_id]
    add_index :coding_region_go_terms,
      [:coding_region_id, :go_term_id, :evidence_code],
      :unique => true
  end

  def self.down
    remove_index :coding_region_go_terms,
      [:coding_region_id, :go_term_id, :evidence_code],
      :unique => true
    add_index :coding_region_go_terms,
      [:coding_region_id, :go_term_id], :unique => true
  end
end
