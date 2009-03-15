class CreateConservedDomains < ActiveRecord::Migration
  def self.up
    create_table :conserved_domains do |t|
      t.integer :coding_region_id, :null => false
      t.string :type, :null => false
      t.string :identifier, :null => false
      t.integer :start, :null => false
      t.integer :stop, :null => false
      t.float :score, :null => false
      t.string :name

      t.timestamps
    end

    add_index :conserved_domains, [:coding_region_id, :type]
  end

  def self.down
    drop_table :conserved_domains
  end
end
