class CreateCds < ActiveRecord::Migration
  def self.up
    create_table :cds do |t|
      t.integer :coding_region_id, :null => false
      t.integer :start, :null => false
      t.integer :end, :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :cds
  end
end
