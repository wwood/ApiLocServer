class MoveCommentsToLocalisationAnnotation < ActiveRecord::Migration
  def self.up
    rename_column :comments, :expression_context_id, :localisation_annotation_id
  end

  def self.down
    rename_column :comments, :localisation_annotation_id, :expression_context_id
  end
end
