class CreateGus < ActiveRecord::Migration
  def self.up
    create_table :gus do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :gus
  end
end
