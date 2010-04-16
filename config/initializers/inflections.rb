# Be sure to restart your server when you modify this file.

# Add new inflection rules using the following format 
# (all these examples are active by default):
# Inflector.inflections do |inflect|
#   inflect.plural /^(ox)$/i, '\1en'
#   inflect.singular /^(ox)en/i, '\1'
#   inflect.irregular 'person', 'people'
#   inflect.uncountable %w( fish sheep )
# end
ActiveSupport::Inflector.inflections do |inflect|
  # By default, coding_region_compartment_caches.singularize => coding_region_compartment_cach
  # when we want coding_region_compartment_cache
  inflect.singular /(^.*ache)s$/, '\1' 
end