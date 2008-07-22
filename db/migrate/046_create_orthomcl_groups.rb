class CreateOrthomclGroups < ActiveRecord::Migration
  def self.up
    create_table :orthomcl_groups do |t|
      t.integer :version
      t.string :orthomcl_name

      t.timestamps
    end
    
    add_index :orthomcl_groups, [:version, :orthomcl_name], :unique => true
  end
  
  

  def self.down
    drop_table :orthomcl_groups
  end
end
