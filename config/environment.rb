# Be sure to restart your server when you modify this file

# Uncomment below to force Rails into production mode when
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'production'

# Specifies gem version of Rails to use when vendor/rails is not present
# Ben removed this because I couldn't be bothered changing manually when
# every new version of rails is released.
RAILS_GEM_VERSION = '2.3.14' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.
  # See Rails::Configuration for more options.

  # Skip frameworks you're not going to use (only works if using vendor/rails).
  # To use Rails without a database, you must remove the Active Record framework
  # config.frameworks -= [ :active_record, :active_resource, :action_mailer ]

  # Only load the plugins named here, in the order given. By default, all plugins 
  # in vendor/plugins are loaded in alphabetical order.
  # :all can be used as a placeholder for all plugins not explicitly named
  # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )

  # Force all environments to use the same logger level
  # (by default production uses :info, the others :debug)
  # config.log_level = :debug

  # Your secret key for verifying cookie session data integrity.
  # If you change this key, all old sessions will become invalid!
  # Make sure the secret is at least 30 characters and all random, 
  # no regular words or you'll be exposed to dictionary attacks.
  config.action_controller.session = {
    :session_key => '_gnr_session',
    :secret      => '56ab42b2d15ac14361e2bb6c202680f976589a9e055752983f66f9070c1ebd35eb995373a00b09b47e499fe907e3db4b72884b32ec67053211143d33596b4b1b'
  }

  # Use the database for sessions instead of the cookie-based default,
  # which shouldn't be used to store highly confidential information
  # (create the session table with 'rake db:sessions:create')
  # config.action_controller.session_store = :active_record_store

  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper,
  # like if you have constraints or database-specific column types
  # config.active_record.schema_format = :sql

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector

  # Make Active Record use UTC-base instead of local time
  # config.active_record.default_timezone = :utc
  
  # Gem dependencies
  %w(reach rarff go fastercsv peach rio array_pair progressbar reubypathdb bio-tm_hmm).each do |i|
    require i
  end
  
  # include a cache sweeper directory that fits into the app/ scheme, as suggested by
  # http://railsenvy.com/2007/2/28/rails-caching-tutorial#sweepers
  config.autoload_paths += %W( #{RAILS_ROOT}/app/sweepers )
end

# Simple class defintions that don't really need their own file since they are too short
class FlorianSecretedTransmembraneDomain < TransmembraneDomain; end
class FlorianErTransmembraneDomain < TransmembraneDomain; end
class FlorianTaTransmembraneDomain < TransmembraneDomain; end
class FlorianGpiTransmembraneDomain < TransmembraneDomain; end
class FlorianFvTransmembraneDomain < TransmembraneDomain; end
class FlorianApicoplastTransmembraneDomain < TransmembraneDomain; end
class FlorianMitochondriaTransmembraneDomain < TransmembraneDomain; end
class FlorianPlasmaMembraneAndAlikeTransmembraneDomain < TransmembraneDomain; end
class FlorianIntracellularTransmembraneDomain < TransmembraneDomain; end
