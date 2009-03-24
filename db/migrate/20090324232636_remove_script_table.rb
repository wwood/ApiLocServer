class RemoveScriptTable < ActiveRecord::Migration
  def self.up
    drop_table :scripts
  end

  def self.down
    create_table :scripts do |t|
      t.timestamps
    end
  end
end
