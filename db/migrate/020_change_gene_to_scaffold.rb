class ChangeGeneToScaffold < ActiveRecord::Migration
  def self.up
    add_column :genes, :scaffold_id, :integer
    remove_column :genes, :species_id
  end

  def self.down
    add_column :genes, :species_id, :integer
    remove_column :genes, :scaffold_id
  end
end
