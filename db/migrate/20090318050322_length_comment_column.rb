class LengthCommentColumn < ActiveRecord::Migration
  def self.up
    change_column :comments, :comment, :text, :ull => false
  end

  def self.down
    change_column :comments, :comment, :string, :ull => false
  end
end
