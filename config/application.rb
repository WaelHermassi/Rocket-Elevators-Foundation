require_relative 'boot'
require 'rails/all'


# Twillo API
require 'rubygems'
require 'twilio-ruby'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module RocketElevatorsInformationSystem
  class Application < Rails::Application
    
    config.api_only = true

    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.2

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    config.middleware.use ActionDispatch::Cookies
    config.middleware.use ActionDispatch::Flash
    config.middleware.use Rack::MethodOverride
    config.middleware.use ActionDispatch::Session::CookieStore, {:key=>"_rocket_elevators_information_system_session"}
    
  end
end
