class CreatePlasmitResults < ActiveRecord::Migration
  def self.up
    create_table :plasmit_results do |t|
      t.integer :coding_region_id, {:null => false, :unique => true}
      t.string :prediction_string, :null => false

      t.timestamps
    end

    add_index :plasmit_results, :coding_region_id
  end

  def self.down
    drop_table :plasmit_results
  end
end
