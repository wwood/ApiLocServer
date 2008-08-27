class AddMousePhenoDescConstraints < ActiveRecord::Migration
  def self.up
    add_index :mouse_pheno_descs, :pheno_id, :unique => true
    add_index :mouse_pheno_descs, [:pheno_desc, :pheno_id], :unique => true
    
    # desc uniq should be true I would think, but isn't (data bug?) so commented out
    #add_index :mouse_pheno_descs, :pheno_desc, :unique => true
  end

  def self.down
    remove_index :mouse_pheno_descs, :pheno_id
    remove_index :mouse_pheno_descs, [:pheno_desc, :pheno_id]
    
    remove_index :mouse_pheno_descs, :pheno_desc

  end
end
