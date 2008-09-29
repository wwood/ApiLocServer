class YetAnotherSpeedup < ActiveRecord::Migration
  def self.up
    add_index :coding_region_alternate_string_ids, :coding_region_id
  end

  def self.down
    add_index :coding_region_alternate_string_ids, :coding_region_id
  end
end
