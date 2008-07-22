class CreateScaffolds < ActiveRecord::Migration
  def self.up
    create_table :scaffolds do |t|
      t.integer :species_id
      t.string :name
      t.timestamps
    end
  end

  def self.down
    drop_table :scaffolds
  end
end
