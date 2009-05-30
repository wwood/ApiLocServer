class SpeedUpCds < ActiveRecord::Migration
  def self.up
    add_index :cds, :stop
    add_index :cds, :start

    add_index :cds, [:stop, :coding_region_id]
    add_index :cds, [:start, :coding_region_id]
  end

  def self.down
    remove_index :cds, :stop
    remove_index :cds, :start

    remove_index :cds, [:stop, :coding_region_id]
    remove_index :cds, [:start, :coding_region_id]
  end
end
