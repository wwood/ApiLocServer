class Scaffold < ActiveRecord::Base
  has_many :genes, :dependent => :destroy
  belongs_to :species
end
