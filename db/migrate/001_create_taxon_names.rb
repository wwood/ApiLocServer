class CreateTaxonNames < ActiveRecord::Migration
  def self.up
    create_table :taxon_names do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :taxon_names
  end
end
