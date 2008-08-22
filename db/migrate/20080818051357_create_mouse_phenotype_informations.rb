class CreateMousePhenotypeInformations < ActiveRecord::Migration
  def self.up
    create_table :mouse_phenotype_informations do |t|
      t.string :mgi_allele, {:null => false}
      t.string :allele_type
      t.string :mgi_marker
      t.integer :gene_id
      t.integer :mouse_pheno_desc_id

      t.timestamps
    end
  end

  def self.down
    drop_table :mouse_phenotype_informations
  end
end
