class CreateNlsDbConsensusSequences < ActiveRecord::Migration
  def self.up
    create_table :nls_db_consensus_sequences do |t|
      t.integer :nls_db_id, :null => false
      t.string :type, :null => false
      t.string :signal, :null => false
      t.string :annotation
      t.integer :pubmed_id

      t.timestamps
    end
  end

  def self.down
    drop_table :nls_db_consensus_sequences
  end
end
