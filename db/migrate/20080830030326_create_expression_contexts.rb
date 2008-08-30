class CreateExpressionContexts < ActiveRecord::Migration
  def self.up
    create_table :expression_contexts do |t|
      t.integer :coding_region_id, :null => false
      t.integer :publication_id
      t.integer :localisation_id
      t.integer :developmental_stage_id

      t.timestamps
    end
    
    add_index :expression_contexts, :coding_region_id
  end

  def self.down
    drop_table :expression_contexts
  end
end
