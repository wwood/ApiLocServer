class CreateOrthomclGeneOrthomclGroupOrthomclRuns < ActiveRecord::Migration
  def self.up
    create_table :orthomcl_gene_orthomcl_group_orthomcl_runs do |t|
      t.integer :orthomcl_gene_id, :null => false
      t.integer :orthomcl_group_id
      t.integer :orthomcl_run_id, :null => false

      t.timestamps
    end
    
    add_index :orthomcl_gene_orthomcl_group_orthomcl_runs, [:orthomcl_gene_id, :orthomcl_run_id, :orthomcl_group_id], :unique => true, :name => 'ogogor'
    add_index :orthomcl_gene_orthomcl_group_orthomcl_runs, [:orthomcl_gene_id, :orthomcl_run_id], :unique => true, :name => 'ogog'
    add_index :orthomcl_gene_orthomcl_group_orthomcl_runs, [:orthomcl_group_id, :orthomcl_run_id], :unique => true, :name => 'ogor'
    
    remove_column :orthomcl_genes, :orthomcl_group_id
    remove_column :orthomcl_groups, :orthomcl_run_id
  end

  def self.down
    drop_table :orthomcl_gene_orthomcl_group_orthomcl_runs
    
    add_column :orthomcl_genes, :orthomcl_group_id, :integer
    add_column :orthomcl_groups, :orthomcl_run_id, :integer
  end
end
