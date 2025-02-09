source 'https://rubygems.org'

ruby '3.4.1'

gem 'rails', '~> 6'

gem 'pg'
gem 'unicorn'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer',  platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2'

# Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
gem 'spring',        group: :development

gem 'haml', '~> 5'
gem 'formtastic'
gem 'responders', '~> 3.1'  # TODO: Where is this used? Can we ditch it? -PPC

gem 'fancybox2-rails'

gem 'annealer'

gem 'icalendar', '~> 2.4'
gem 'redcarpet', '~> 3.1'
gem 'bcrypt-ruby', '~> 3.1'
gem 'authlogic', '~> 6'
gem 'cancancan'

gem 'nokogiri'

# FFI 1.17+ isn't compatible with Ruby 2.x on Linux, which breaks GitHub Actions.
# Remove this line when upgrading to Ruby 3.
gem 'ffi', '~> 1.16.3'

group :development, :test do
  gem 'ffaker'
  gem 'ruby-progressbar', require: false
  gem "rspec-rails", "~> 6"
  gem 'rails-controller-testing'
  gem 'capybara'
  gem 'pry'
  gem "simplecov", "~> 0.22.0"
end

group :test do
  gem 'shoulda-matchers'
  gem 'factory_bot_rails'
  gem 'database_cleaner'
  gem "selenium-webdriver", "~> 4.9"
  gem 'puma'
  gem "csv", "~> 3.3"
  gem "benchmark", "~> 0.4.0"
end

#https://devcenter.heroku.com/articles/rails-4-asset-pipeline
gem 'rails_12factor', group: :production


# -----------------------------------------------------------------------------
# Compatibility shims: Necessary to make old gems work with new Rubies.
# These may be removable as we upgrade gems above.
# 
gem "mutex_m", "~> 0.3.0"
gem "bigdecimal", "~> 3.1"
gem 'concurrent-ruby', '1.3.4'
gem "drb", "~> 2.2"
#
# -----------------------------------------------------------------------------

