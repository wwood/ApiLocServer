class FlexibalizeMinTransmembraneTable < ActiveRecord::Migration
  def self.up
    add_column :min_transmembrane_domain_lengths, :type, :string, {:null => false, :default => 'MinTransmembraneDomainLength'}
    rename_column :min_transmembrane_domain_lengths, :domain_length, :measurement
    
    remove_index :min_transmembrane_domain_lengths, [:coding_region_id]
    add_index :min_transmembrane_domain_lengths, [:coding_region_id, :type], :unique => true
    
    rename_table :min_transmembrane_domain_lengths, :transmembrane_domain_measurements
    
    
  end

  def self.down
    remove_index :min_transmembrane_domain_lengths, [:coding_region_id]
    add_index :min_transmembrane_domain_lengths, [:coding_region_id, :type], :unique => true
    
    rename_table :transmembrane_domain_measurements, :min_transmembrane_domain_lengths
    remove_column :min_transmembrane_domain_lengths, :type
    rename_column :min_transmembrane_domain_lengths, :measurement, :domain_length
  end
end

