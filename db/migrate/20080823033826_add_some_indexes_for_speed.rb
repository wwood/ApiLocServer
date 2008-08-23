class AddSomeIndexesForSpeed < ActiveRecord::Migration
  def self.up
    add_index :phenotype_informations, [:coding_region_id]
    add_index :phenotype_observeds, [:coding_region_id]
  end

  def self.down
    remove_index :phenotype_informations, [:coding_region_id]
    remove_index :phenotype_observeds, [:coding_region_id]
  end
end
