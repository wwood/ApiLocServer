class CreateMousePhenoInfos < ActiveRecord::Migration
  def self.up
    create_table :mouse_pheno_infos do |t|
      t.string :mgi_allele, {:null => false}
      t.string :allele_type
      t.string :mgi_marker
      t.string :gene
      t.string :phenotype

      t.timestamps
    end
  end

  def self.down
    drop_table :mouse_pheno_infos
  end
end
