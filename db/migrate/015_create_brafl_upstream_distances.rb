class CreateBraflUpstreamDistances < ActiveRecord::Migration
  def self.up
    create_table :brafl_upstream_distances do |t|
      t.integer :go_term_id, :null => false
      t.integer :upstream_distance, :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :brafl_upstream_distances
  end
end
