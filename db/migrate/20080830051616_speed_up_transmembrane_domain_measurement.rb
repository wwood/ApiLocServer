class SpeedUpTransmembraneDomainMeasurement < ActiveRecord::Migration
  def self.up
    add_index :transmembrane_domain_measurements, :coding_region_id
  end

  def self.down
    remove_index :transmembrane_domain_measurements, :coding_region_id
  end
end
