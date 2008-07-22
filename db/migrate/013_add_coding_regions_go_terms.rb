class AddCodingRegionsGoTerms < ActiveRecord::Migration
  def self.up
    create_table :coding_region_go_terms do |t|
      t.integer :coding_region_id
      t.integer :go_term_id
    end
  end

  def self.down
    drop_table :coding_region_go_terms
  end
end
