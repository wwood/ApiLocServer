class CreateGoListEntries < ActiveRecord::Migration
  def self.up
    create_table :go_list_entries do |t|
      t.integer :go_list_id
      t.integer :go_term_id
      t.timestamps
    end
  end

  def self.down
    drop_table :go_list_entries
  end
end
