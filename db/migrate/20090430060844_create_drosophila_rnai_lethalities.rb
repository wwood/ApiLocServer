class CreateDrosophilaRnaiLethalities < ActiveRecord::Migration
  def self.up
    create_table :drosophila_rnai_lethalities do |t|
      t.string :lethality, :null => false

      t.timestamps
    end
  
     add_index :drosophila_rnai_lethalities, :lethality, :unique => true
  
  end

  def self.down
    drop_table :drosophila_rnai_lethalities
  end
end
