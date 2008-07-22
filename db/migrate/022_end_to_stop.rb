class EndToStop < ActiveRecord::Migration
  def self.up
    rename_column :cds, :end, :stop
  end

  def self.down
    rename_column :cds, :stop, :end
  end
end
