class RemoveVerificationTable < ActiveRecord::Migration
  def self.up
    drop_table :verifications
  end

  def self.down
    raise
  end
end
