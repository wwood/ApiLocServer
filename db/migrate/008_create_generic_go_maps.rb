class CreateGenericGoMaps < ActiveRecord::Migration
  def self.up
    create_table :generic_go_maps do |t|
      t.integer :child_id
      t.integer :parent_id
      t.timestamps
    end
  end

  def self.down
    drop_table :generic_go_maps
  end
end
