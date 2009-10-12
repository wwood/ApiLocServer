class CreateLocalisationAnnotations < ActiveRecord::Migration
  def self.up
    create_table :localisation_annotations do |t|
      t.text :localisation
      t.text :gene_mapping_comments
      t.string :microscopy_type
      t.string :microscopy_method
      t.text :quote
      t.string :strain

      t.timestamps
    end

    add_column :expression_contexts, :localisation_annotation_id, :integer, :null => false
  end

  def self.down
    remove_column :expression_contexts, :localisation_annotation_id
    drop_table :localisation_annotations
  end
end
