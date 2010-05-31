class AdditionOfEvidenceCodedExpressionContextSoSecondClassCitizensFit < ActiveRecord::Migration
  def self.up
    # make expression context a subclass of EvidenceCodedExpressionContext
    add_column :expression_contexts, :type, :string, :null => false, :default => 'ExpressionContext'
    rename_table :expression_contexts, :evidence_coded_expression_contexts
  end
  
  def self.down
    rename_table :evidence_coded_expression_contexts, :expression_contexts
    remove_column :expression_contexts, :type
  end
end
