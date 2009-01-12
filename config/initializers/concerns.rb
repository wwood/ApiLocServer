# Copied directly from http://m.onkey.org/2008/9/15/active-record-tips-and-tricks
# 25 Nov 2008
class << ActiveRecord::Base
  def concerned_with(*concerns)
    concerns.each do |concern|
      require_dependency "#{name.underscore}/#{concern}"
    end
  end
end