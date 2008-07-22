class CreateClustersets < ActiveRecord::Migration
  def self.up
    create_table :clustersets do |t|
      t.string :name
      t.timestamps
    end
  end

  def self.down
    drop_table :clustersets
  end
end
