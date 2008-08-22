class CreateMverifications < ActiveRecord::Migration
  def self.up
    create_table :mverifications do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :mverifications
  end
end
