class CreateGoTerms < ActiveRecord::Migration
  def self.up
    create_table :go_terms do |t|
      t.string :go_identifier
      t.string :term
      t.string :aspect
      t.timestamps
    end
  end

  def self.down
    drop_table :go_terms
  end
end
