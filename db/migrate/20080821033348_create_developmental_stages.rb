class CreateDevelopmentalStages < ActiveRecord::Migration
  def self.up
    create_table :developmental_stages do |t|
      t.string :type
      t.string :name

      t.timestamps
    end
  end

  def self.down
    drop_table :developmental_stages
  end
end
