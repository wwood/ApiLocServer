class CreateTaxons < ActiveRecord::Migration
  def self.up
    create_table :taxons do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :taxons
  end
end
