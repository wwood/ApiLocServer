class CreateAnnotations < ActiveRecord::Migration
  def self.up
    create_table :annotations do |t|
      t.references :coding_region
      t.string :annotation

      t.timestamps
    end
    
    add_index :annotations, [:coding_region_id, :annotation], :unique => true
  end

  def self.down
    drop_table :annotations
  end
end
