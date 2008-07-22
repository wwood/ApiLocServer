class CreateProbeMaps < ActiveRecord::Migration
  def self.up
    create_table :probe_maps do |t|
      t.string :name, :null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :probe_maps
  end
end
