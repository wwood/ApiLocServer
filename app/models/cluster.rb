class Cluster < ActiveRecord::Base
  belongs_to :clusterset
  has_many :cluster_entries, :dependent => :destroy
end
