class RenameAndReconceptualiseNlsToUnderstandOtherSignals < ActiveRecord::Migration
  def self.up
    rename_table :nls_db_consensus_sequences, :consensus_sequences
    change_column :consensus_sequences, :nls_db_id, :integer, :null => true
  end

  def self.down
    rename_table :consensus_sequences, :nls_db_consensus_sequences
    change_column :nls_db_consensus_sequences, :nls_db_id, :integer, :null => true
  end
end
