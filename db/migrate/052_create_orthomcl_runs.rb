class CreateOrthomclRuns < ActiveRecord::Migration
  def self.up
    create_table :orthomcl_runs do |t|
      t.string :name, :null => false

      t.timestamps
    end
    
    OrthomclRun.reset_column_information
    
    default_run = OrthomclRun.create(
      :name => "Official OrthoMCL v2"
    )
    
    add_column :orthomcl_groups, 
      :orthomcl_run_id, 
      :integer,
      {
      :default => default_run.id, 
      :null => false
    }
    
    change_column :orthomcl_groups, :orthomcl_run_id, :integer, :default => nil
  end

  def self.down
    remove_column :orthomcl_groups, :orthomcl_run_id
    drop_table :orthomcl_runs
  end
end
