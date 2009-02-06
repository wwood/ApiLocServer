class CreateUserComments < ActiveRecord::Migration
  def self.up
    create_table :user_comments do |t|
      t.string :title, :limit => 50, :null => false
      t.string :comment, :null => false
      t.integer :user_id #not yet a real table
      t.integer :coding_region_id, :null => false
      t.integer :number, :null => false

      t.timestamps
    end
    
    add_index :user_comments, [:coding_region_id]
    add_index :user_comments, [:coding_region_id, :number], :unique => true
  end

  def self.down
    drop_table :user_comments
  end
end
