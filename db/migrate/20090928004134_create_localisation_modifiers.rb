class CreateLocalisationModifiers < ActiveRecord::Migration
  def self.up
    create_table :localisation_modifiers do |t|
      t.string :modifier, :uniq => true, :null => false

      t.timestamps
    end

    add_column :expression_contexts, :localisation_modifier_id, :integer
  end

  def self.down
    drop_table :localisation_modifiers
    remove_column :expression_contexts, :localisation_modifier_id
  end
end
