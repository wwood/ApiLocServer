class RelaxTrasmembraneDomainConstraints < ActiveRecord::Migration
  def self.up
    # It is a non-standard index name for legacy reasons that noone really cares about now
    remove_index :min_transmembrane_domain_lengths, 'coding_region_id_and_type'
  end

  def self.down
    add_index :min_transmembrane_domain_lengths, [:coding_region_id, :type], {
      :unique => true, :name => 'index_min_transmembrane_domain_lengths_on_coding_region_id_and_type'}
  end
end
