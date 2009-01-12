class CreateWolfPsortPredictions < ActiveRecord::Migration
  def self.up
    create_table :wolf_psort_predictions do |t|
      t.integer :coding_region_id
      t.string :organism_type
      t.string :localisation
      t.decimal :score

      t.timestamps
    end
    
    add_index :wolf_psort_predictions, :coding_region_id
  end

  def self.down
    drop_table :wolf_psort_predictions
  end
end
