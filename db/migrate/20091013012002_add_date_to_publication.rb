class AddDateToPublication < ActiveRecord::Migration
  def self.up
    add_column :publications, :date, :string
  end

  def self.down
    remove_column :publications, :date
  end
end
