class CreateMousePhenoDescs < ActiveRecord::Migration
  def self.up
    create_table :mouse_pheno_descs do |t|
      t.string :pheno_id, {:null => false}
      t.string :pheno_desc

      t.timestamps
    end
  end

  def self.down
    drop_table :mouse_pheno_descs
  end
end
