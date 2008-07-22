class CreateSpecies < ActiveRecord::Migration
  def self.up
    create_table :species do |t|
      t.string :name
      t.timestamps
    end
    
    Species.reset_column_information
    Species.create!(
      :id => 1,
      :name => 'brafl'
    )
    Species.create!(
      :id => 2,
      :name => 'falciparum'
    )
  end

  def self.down
    drop_table :species
  end
end
