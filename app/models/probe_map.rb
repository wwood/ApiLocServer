class ProbeMap < ActiveRecord::Base
  has_many :probe_map_entries, :dependent => :destroy
end
