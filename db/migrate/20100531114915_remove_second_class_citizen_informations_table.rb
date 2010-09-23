class RemoveSecondClassCitizenInformationsTable < ActiveRecord::Migration
  def self.up
    drop_table :second_class_citizen_informations
  end
  
  def self.down
    create_table :second_class_citizen_informations do |t|
      t.integer :evidence_coded_expression_context_id
      t.string :gene_mapping_comments
      t.string :reasoning
      
      t.timestamps
    end
    add_foreign_key(:second_class_citizen_informations, :evidence_coded_expression_contexts, {:dependent=>:delete, :name => 'second_class_citizen_informations_evidence_coded_expression_con'})
    add_index :second_class_citizen_informations, :evidence_coded_expression_context_id, :name => 'index_second_class_citizen_informations_on_evidence_coded_expre'
  end
end