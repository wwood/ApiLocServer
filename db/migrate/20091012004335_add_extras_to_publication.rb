class AddExtrasToPublication < ActiveRecord::Migration
  def self.up
    add_column :publications, :title, :text
    add_column :publications, :authors, :text
    add_column :publications, :abstract, :text
  end

  def self.down
    remove_column :publications, :title, :text
    remove_column :publications, :authors, :text
    remove_column :publications, :abstract, :text
  end
end
