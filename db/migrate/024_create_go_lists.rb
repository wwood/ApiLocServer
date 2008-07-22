class CreateGoLists < ActiveRecord::Migration
  def self.up
    create_table :go_lists do |t|
      t.string :name
      t.timestamps
    end
  end

  def self.down
    drop_table :go_lists
  end
end
