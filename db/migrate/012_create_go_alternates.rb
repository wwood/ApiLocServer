class CreateGoAlternates < ActiveRecord::Migration
  
  INDEX_NAME = 'go_alternate_index'
  
  def self.up
    create_table :go_alternates do |t|
      t.string :go_identifier
      t.integer :go_term_id
      t.timestamps
    end
    
    add_index :go_alternates, [:go_identifier], :unique => true
#    execute "create unique index #{INDEX_NAME} on go_alternates (go_identifier)"
  end

  def self.down
    drop_table :go_alternates
  end
end
