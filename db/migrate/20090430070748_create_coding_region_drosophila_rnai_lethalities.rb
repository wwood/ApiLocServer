class CreateCodingRegionDrosophilaRnaiLethalities < ActiveRecord::Migration
  def self.up
    create_table :coding_region_drosophila_rnai_lethalities do |t|
      t.integer :coding_region_id, :null => false
      t.integer :drosophila_rnai_lethality_id, :null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :coding_region_drosophila_rnai_lethalities
  end
end
