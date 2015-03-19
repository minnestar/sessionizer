# Be sure to restart your server when you modify this file.

Sessionizer::Application.config.session_store :cookie_store, key: '_sessionizer_session'

#ActionController::Base.session = {
  #:key         => '_sessionizer_session',
  #:secret      => '290f611ddba37e51e985ceb4d84ba63dc69dc580d29646e174a98c08b1b7a8a7e6a450c0373e52684dab328e0648c310812b91278d32f2926bc95add4b3a8d24'
#}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rails generate session_migration")
# Sessionizer::Application.config.session_store :active_record_store
