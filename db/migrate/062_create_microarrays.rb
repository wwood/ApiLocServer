class CreateMicroarrays < ActiveRecord::Migration
  def self.up
    create_table :microarrays do |t|
      t.string :description, :unique => true

      t.timestamps
    end
    
  end

  def self.down
    drop_table :microarrays
  end
end
