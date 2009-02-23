class FixChromosomalFeature < ActiveRecord::Migration
  def self.up
    add_column :chromosomal_features, :type, :string, :null => false
    add_column :chromosomal_features, :value, :integer, :null => false
  end

  def self.down
    remove_column :chromosomal_features, :type
    remove_column :chromosomal_features, :value
  end
end
