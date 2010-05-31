class CreateSecondClassCitizenInformations < ActiveRecord::Migration
  def self.up
    create_table :second_class_citizen_informations do |t|
      t.integer :evidence_coded_expression_context_id
      t.string :gene_mapping_comments
      t.string :reasoning
      
      t.timestamps
    end
    #    foreign key added in another migration because rails refused to do it all at once
    add_foreign_key(:second_class_citizen_informations, :evidence_coded_expression_contexts, {:dependent=>:delete})
    add_index :second_class_citizen_informations, :evidence_coded_expression_context_id
  end
  
  def self.down
    drop_table :second_class_citizen_informations
  end
end
