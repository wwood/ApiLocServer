class CreateClusters < ActiveRecord::Migration
  def self.up
    create_table :clusters do |t|
      t.integer :clusterset_id
      t.integer :published_number
      t.timestamps
    end
  end

  def self.down
    drop_table :clusters
  end
end
