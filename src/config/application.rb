require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Sessionizer
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    config.eager_load_paths << config.root.join('lib')

    # We want to always show times in Minnebar’s time zone, regardless of where
    # the use is located.

    config.time_zone = 'US/Central'
  end
end
