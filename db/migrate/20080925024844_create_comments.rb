class CreateComments < ActiveRecord::Migration
  def self.up
    create_table :comments do |t|
      t.integer :expression_context_id, :null => false
      t.string :comment, :null => false

      t.timestamps
    end
    
    add_index :comments, :expression_context_id
  end

  def self.down
    drop_table :comments
  end
end
