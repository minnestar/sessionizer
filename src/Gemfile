source 'https://rubygems.org'

ruby '2.4.2'

gem 'rails', '5.1.4'

gem 'pg'
#gem 'sqlite3'
gem 'unicorn'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0.3'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.2'
# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer',  platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0',          group: :doc

# Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
gem 'spring',        group: :development

gem 'haml'
gem 'formtastic'
gem 'responders', '~> 2.0'

#gem "fancybox-rails", "~> 0.2.1"
gem 'fancybox2-rails'

gem 'annealer'

# TODO
gem 'icalendar', '~> 1.5.4'
gem 'redcarpet', '~> 3.1'
gem 'bcrypt-ruby', '~> 3.1'
gem 'authlogic'
gem 'cancancan'

gem 'nokogiri'

group :development, :test do
  gem 'ffaker'
  gem 'ruby-progressbar', require: false
  gem "rspec-rails", "~> 3.1"
  gem 'rails-controller-testing'
  gem 'capybara'
  gem 'pry'
  gem 'coveralls', require: false
end

group :test do
  gem 'shoulda-matchers'
  gem "factory_girl_rails", "~> 4.0"
  gem 'database_cleaner'
  gem 'poltergeist'
end

#https://devcenter.heroku.com/articles/rails-4-asset-pipeline
gem 'rails_12factor', group: :production
