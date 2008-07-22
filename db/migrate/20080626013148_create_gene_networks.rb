class CreateGeneNetworks < ActiveRecord::Migration
  def self.up
    create_table :gene_networks do |t|
      t.string :name

      t.timestamps
    end
  end

  def self.down
    drop_table :gene_networks
  end
end
