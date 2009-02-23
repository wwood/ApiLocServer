class Scaffold < ActiveRecord::Base
  has_many :genes, :dependent => :destroy
  has_many :chromosomal_features, :dependent => :destroy
  belongs_to :species
end
