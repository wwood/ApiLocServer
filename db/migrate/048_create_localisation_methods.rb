class CreateLocalisationMethods < ActiveRecord::Migration
  def self.up
    create_table :localisation_methods do |t|
      t.string :description

      t.timestamps
    end
    
    add_index :localisation_methods, :description, :unique => true
  end

  def self.down
    drop_table :localisation_methods
  end
end
