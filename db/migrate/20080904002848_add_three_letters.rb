class AddThreeLetters < ActiveRecord::Migration
  def self.up
    add_column :species, :orthomcl_three_letter, :string, :length => 3, :uniq => true
  end

  def self.down
    remove_column :species, :orthomcl_three_letter
  end
end
