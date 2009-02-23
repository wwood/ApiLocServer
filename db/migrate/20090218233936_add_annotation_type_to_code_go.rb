class AddAnnotationTypeToCodeGo < ActiveRecord::Migration
  def self.up
    add_column :coding_region_go_terms, :evidence_code, :string, :length => 3
  end

  def self.down
    remove_column :coding_region_go_terms, :evidence_code, :string
  end
end
