#!/bin/bash

echo '--------------'
echo 'bundle install'
bundle install

echo '----------------'
echo 'rails db:migrate'
rails db:migrate

echo '----------------------'
echo 'bundle exec rspec spec'
bundle exec rspec spec
