class AddGoTermIndex < ActiveRecord::Migration
  def self.up
    add_index :go_terms, [:go_identifier, :term, :aspect]
  end

  def self.down
    remove_index :go_terms, [:go_identifier, :term, :aspect]
  end
end
