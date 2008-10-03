class ClearOldTablesGivenExpressionContext < ActiveRecord::Migration
  def self.up
    drop_table :localisation_literatures
    drop_table :developmental_stage_localisations
    drop_table :developmental_stage_localisation_publications
  end

  def self.down
    raise
  end
end
