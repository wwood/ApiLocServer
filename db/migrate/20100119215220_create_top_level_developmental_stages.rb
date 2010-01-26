class CreateTopLevelDevelopmentalStages < ActiveRecord::Migration
  def self.up
    create_table :top_level_developmental_stages do |t|
      t.string :name, :null => false, :unique => true

      t.timestamps
    end
  end

  def self.down
    drop_table :top_level_developmental_stages
  end
end
