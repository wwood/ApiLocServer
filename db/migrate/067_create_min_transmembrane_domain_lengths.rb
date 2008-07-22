class CreateMinTransmembraneDomainLengths < ActiveRecord::Migration
  def self.up
    create_table :min_transmembrane_domain_lengths do |t|
      t.integer :coding_region_id
      t.integer :domain_length

      t.timestamps
    end
    
    add_index :min_transmembrane_domain_lengths, :coding_region_id, :unique => true
  end

  def self.down
    drop_table :min_transmembrane_domain_lengths
  end
end
