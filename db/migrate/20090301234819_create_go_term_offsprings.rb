class CreateGoTermOffsprings < ActiveRecord::Migration
  def self.up
    create_table :go_term_offsprings do |t|
      t.integer :go_term_id, :null => false
      t.integer :offspring_go_term_id, :null => false

      t.timestamps
    end

    add_index :go_term_offsprings, :go_term_id
    add_index :go_term_offsprings, [:go_term_id, :offspring_go_term_id], :unique => true
  end

  def self.down
    drop_table :go_term_offsprings
  end
end
