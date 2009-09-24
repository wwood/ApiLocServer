class ChangeIndexRulesOnAlternateCodingRegionIds < ActiveRecord::Migration
  def self.up
    # remove the :uniq constraint, because now there is sub-types
    remove_index :coding_region_alternate_string_ids, [:coding_region_id, :name]
    add_index :coding_region_alternate_string_ids, [:coding_region_id, :name], :name => 'index3'
    
    add_index :coding_region_alternate_string_ids, [:coding_region_id, :name, :type], :unique => true, :name => 'index4'
  end

  def self.down
    add_index :coding_region_alternate_string_ids, [:coding_region_id, :name], :unique =>true
    remove_index :coding_region_alternate_string_ids, [:coding_region_id, :name], :name => 'index3'
    remove_index :coding_region_alternate_string_ids, [:coding_region_id, :name, :type], :name => 'index4'
  end
end
