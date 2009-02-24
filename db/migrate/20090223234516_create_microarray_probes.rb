class CreateMicroarrayProbes < ActiveRecord::Migration
  def self.up
    create_table :microarray_probes do |t|
      t.integer :microarray_id, :null => false
      t.string :probe, :null => false

      t.timestamps
    end

    add_index :microarray_probes, :microarray_id
    add_index :microarray_probes, :probe
    add_index :microarray_probes, [:probe, :microarray_id]
  end

  def self.down
    drop_table :microarray_probes
  end
end
