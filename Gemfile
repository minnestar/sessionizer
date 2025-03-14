source 'https://rubygems.org'

ruby '3.4.1'

gem 'rails', '~> 7'

gem 'pg'
gem 'unicorn'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
gem 'terser', '~> 1.2'
# gem 'therubyracer',  platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2'

# Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
gem 'spring', group: :development

gem 'haml', '~> 6'
gem 'formtastic'
gem 'responders', '~> 3.1'

gem 'fancybox2-rails'

gem 'annealer'

gem 'icalendar', '~> 2.4'
gem 'redcarpet', '~> 3.1'
gem 'bcrypt-ruby', '~> 3.1'
gem 'authlogic', '~> 6'
gem 'cancancan'
gem 'csv', '~> 3.3'
gem 'nokogiri'

# active admin
gem 'devise'
gem 'activeadmin'

group :development, :test do
  gem 'ffaker'
  gem 'ruby-progressbar', require: false
  gem "rspec-rails", "~> 7.1"
  gem 'rails-controller-testing'
  gem 'capybara'
  gem 'pry'
  gem "simplecov", "~> 0.22.0"
  gem "letter_opener", "~> 1.10"
end

group :test do
  gem 'shoulda-matchers'
  gem 'factory_bot_rails'
  gem 'database_cleaner'
  gem "selenium-webdriver", "~> 4.9"
  gem 'puma'
  gem "benchmark", "~> 0.4"
end

#https://devcenter.heroku.com/articles/rails-4-asset-pipeline
gem 'rails_12factor', group: :production
