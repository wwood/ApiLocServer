class MicroarrayTimepoint < ActiveRecord::Base
  has_many :microarray_measurements, :dependent => :destroy
  belongs_to :microarray
end
