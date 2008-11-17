class CreateExportPreds < ActiveRecord::Migration
  def self.up
    create_table :export_preds do |t|
      t.integer :coding_region_id, :null => false
      t.boolean :predicted
      t.decimal :score

      t.timestamps
    end
  end

  def self.down
    drop_table :export_preds
  end
end
