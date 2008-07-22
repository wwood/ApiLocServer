class AddDerisilogmeanDummy < ActiveRecord::Migration
  def self.up
    create_table :derisi20063d7logmean do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :derisi20063d7logmean
  end
end
