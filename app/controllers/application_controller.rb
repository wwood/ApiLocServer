# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => 'db24b81d2e5a7ae24451ee5970875118'

  # include mixin as from the README at http://github.com/rails/exception_notification
  include ExceptionNotifiable
  local_addresses.clear
end
