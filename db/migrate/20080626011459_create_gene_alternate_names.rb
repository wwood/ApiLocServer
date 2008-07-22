class CreateGeneAlternateNames < ActiveRecord::Migration
  def self.up
    create_table :gene_alternate_names do |t|
      t.integer :gene_id
      t.string :name

      t.timestamps
    end
    
    add_index :gene_alternate_names, [:gene_id]
    add_index :gene_alternate_names, [:name]
  end

  def self.down
    drop_table :gene_alternate_names
  end
end
