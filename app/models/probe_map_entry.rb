class ProbeMapEntry < ActiveRecord::Base
  belongs_to :probe_map
  belongs_to :coding_region
end
