class CreateChromosomalFeatures < ActiveRecord::Migration
  def self.up
    create_table :chromosomal_features do |t|
      t.integer :start, :null => false
      t.integer :stop, :null => false
      t.integer :scaffold_id, :null => false

      t.timestamps
    end
    
    add_index :chromosomal_features, :scaffold_id
  end

  def self.down
    drop_table :chromosomal_features
  end
end
