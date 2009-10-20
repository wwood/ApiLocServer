class CreateGoTermLocalisations < ActiveRecord::Migration
  def self.up
    create_table :go_term_localisations do |t|
      t.integer :go_term_id, :null => false
      t.integer :localisation_id, :null => false

      t.timestamps
    end

    add_index :go_term_localisations, :go_term_id
    add_index :go_term_localisations, :localisation_id
  end

  def self.down
    drop_table :go_term_localisations
  end
end
