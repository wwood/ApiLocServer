class AddJournalToPublication < ActiveRecord::Migration
  def self.up
    add_column :publications, :journal, :string
  end

  def self.down
    remove_column :publications, :journal
  end
end
