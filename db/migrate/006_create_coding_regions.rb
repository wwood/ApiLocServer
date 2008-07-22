class CreateCodingRegions < ActiveRecord::Migration
  def self.up
    create_table :coding_regions do |t|
      t.integer :gene_id
      t.integer :jgi_protein_id
      t.integer :upstream_distance
      t.timestamps
    end
  end

  def self.down
    drop_table :coding_regions
  end
end
