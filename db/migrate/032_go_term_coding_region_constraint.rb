class GoTermCodingRegionConstraint < ActiveRecord::Migration
  def self.up
    add_index :coding_region_go_terms, 
      [:coding_region_id, :go_term_id], 
      :unique => true
  end

  def self.down
    remove_index :coding_region_go_terms, 
      [:coding_region_id, :go_term_id]
  end
end
