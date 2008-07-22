class ChangeAnnotationSoLonger < ActiveRecord::Migration
  def self.up
    change_column :annotations, :annotation, :text, :null => false
  end

  def self.down
    change_column :annotations, :annotation, :string
  end
end
