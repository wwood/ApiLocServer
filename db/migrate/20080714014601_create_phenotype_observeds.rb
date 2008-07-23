class CreatePhenotypeObserveds < ActiveRecord::Migration
  def self.up
    create_table :phenotype_observeds do |t|
      t.integer :coding_region_id, {:null => false}
      t.string :dbxref
      t.string :phenotype
      t.integer :experiments
      t.integer :primary
      t.integer :specific
      t.integer :observed

      t.timestamps
    end
  end

  def self.down
    drop_table :phenotype_observeds
  end
end
