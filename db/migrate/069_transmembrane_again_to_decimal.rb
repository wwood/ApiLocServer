class TransmembraneAgainToDecimal < ActiveRecord::Migration
  def self.up
    change_column :transmembrane_domain_measurements, :measurement, :decimal, :null => false
  end

  def self.down
    change_column :transmembrane_domain_measurements, :measurement, :integer, :null => false
  end
end
