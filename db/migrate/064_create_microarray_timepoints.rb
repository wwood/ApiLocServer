class CreateMicroarrayTimepoints < ActiveRecord::Migration
  def self.up
    create_table :microarray_timepoints do |t|
      t.integer :microarray_id
      t.string :name

      t.timestamps
    end
    
    add_index :microarray_timepoints, [:microarray_id, :name], :unique => true
  end

  def self.down
    drop_table :microarray_timepoints
  end
end
