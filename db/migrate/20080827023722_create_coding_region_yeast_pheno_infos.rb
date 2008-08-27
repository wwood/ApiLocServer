class CreateCodingRegionYeastPhenoInfos < ActiveRecord::Migration
  def self.up
    create_table :coding_region_yeast_pheno_infos do |t|
      t.integer :coding_region_id, :null => false
      t.integer :yeast_pheno_info_id, :null => false

      t.timestamps
    end
    
    add_index :coding_region_yeast_pheno_infos, [:coding_region_id, :yeast_pheno_info_id], :unique => true
    
    remove_column :yeast_pheno_info, :coding_region_id
  end

  def self.down
    drop_table :coding_region_yeast_pheno_infos
    
    add_column :yeast_pheno_info, :coding_region_id, :integer, :null => false
  end
end
