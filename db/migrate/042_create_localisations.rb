class CreateLocalisations < ActiveRecord::Migration
  def self.up
    create_table :localisations do |t|
      t.string :name, :null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :localisations
  end
end
