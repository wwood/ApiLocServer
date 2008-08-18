class CreateLocalisationLiteratures < ActiveRecord::Migration
  def self.up
    create_table :localisation_literatures do |t|
      t.integer :pmid, :null =>false
      t.integer :localisation_method_id, :null =>false

      t.timestamps
    end
  end

  def self.down
    drop_table :localisation_literatures
  end
end
