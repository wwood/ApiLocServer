class CreateOrthomclGenes < ActiveRecord::Migration
  def self.up
    create_table :orthomcl_genes do |t|
      t.string :orthomcl_name
      t.references :orthomcl_group

      t.timestamps
    end
    
    add_index :orthomcl_genes, [:orthomcl_group_id, :orthomcl_name], :unique => true
  end

  def self.down
    drop_table :orthomcl_genes
  end
end
