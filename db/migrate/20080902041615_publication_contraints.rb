class PublicationContraints < ActiveRecord::Migration
  def self.up
    change_column :publications, :pubmed_id, :integer, :unique => false
  end

  def self.down
    change_column :publications, :pubmed_id, :integer
  end
end
