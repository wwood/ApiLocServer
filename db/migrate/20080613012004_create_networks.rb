class CreateNetworks < ActiveRecord::Migration
  def self.up
    create_table :networks do |t|
      t.string :name

      t.timestamps
      
    end
    
    add_index :networks, :name, :unique => true
  end

  def self.down
    drop_table :networks
  end
end
