class Clusterset < ActiveRecord::Base
  has_many :clusters, :dependent => :destroy
end
