# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_sessionizer_session',
  :secret      => '290f611ddba37e51e985ceb4d84ba63dc69dc580d29646e174a98c08b1b7a8a7e6a450c0373e52684dab328e0648c310812b91278d32f2926bc95add4b3a8d24'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
