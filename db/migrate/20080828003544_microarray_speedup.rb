class MicroarraySpeedup < ActiveRecord::Migration
  def self.up
    add_index :microarray_measurements, :coding_region_id
  end

  def self.down
  end
end
