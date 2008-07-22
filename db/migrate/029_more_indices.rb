class MoreIndices < ActiveRecord::Migration
  def self.up
    add_index :coding_regions, :gene_id
  end

  def self.down
    remove_index :coding_regions, :gene_id
  end
end
