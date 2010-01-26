class CreateDevelopmentalStageTopLevelDevelopmentalStages < ActiveRecord::Migration
  def self.up
    create_table :developmental_stage_top_level_developmental_stages do |t|
      t.references :developmental_stage, :foreign_key => {:dependant => :delete}
      t.references :top_level_developmental_stage, :foreign_key => {:dependant => :delete}

      t.timestamps
    end
  end

  def self.down
    drop_table :developmental_stage_top_level_developmental_stages
  end
end
