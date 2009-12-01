class CreateBlastHits < ActiveRecord::Migration
  def self.up
    create_table :blast_hits do |t|
      t.integer :coding_region_id, :null => false
      t.integer :hit_coding_region_id, :null => false
      t.double :evalue, :null => false

      t.timestamps
    end

    add_index :blast_hits, :coding_region_id
    add_index :blast_hits, [:coding_region_id, :hit_coding_region_id], :unique => true
  end

  def self.down
    drop_table :blast_hits
  end
end
