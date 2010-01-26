class CreateOrthomclLocalisationConservations < ActiveRecord::Migration
  def self.up
    create_table :orthomcl_localisation_conservations do |t|
      t.integer :orthomcl_group_id, :null => false
      t.string :conservation, :null => false

      t.timestamps
    end

    add_index :orthomcl_localisation_conservations, :orthomcl_group_id
    add_index :orthomcl_localisation_conservations, :conservation
  end

  def self.down
    drop_table :orthomcl_localisation_conservations
  end
end
