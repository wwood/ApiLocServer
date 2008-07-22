class CreateGoMaps < ActiveRecord::Migration
  def self.up
    create_table :go_maps do |t|
      t.string :name
      t.timestamps
    end
  end

  def self.down
    drop_table :go_maps
  end
end
