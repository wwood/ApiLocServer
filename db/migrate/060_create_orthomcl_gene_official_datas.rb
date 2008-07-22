class CreateOrthomclGeneOfficialDatas < ActiveRecord::Migration
  def self.up
    create_table :orthomcl_gene_official_datas do |t|
      t.integer :orthomcl_gene_id
      t.text :sequence
      t.text :annotation

      t.timestamps
    end
  end

  def self.down
    drop_table :orthomcl_gene_official_datas
  end
end
