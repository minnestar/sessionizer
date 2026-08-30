# Be sure to restart your server when you modify this file.

# Disable SassC CSS compressor to avoid issues with modern CSS syntax
Rails.application.config.assets.css_compressor = nil

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = "1.0"

# Add additional assets to the asset load path.
# Rails.application.config.assets.paths << Emoji.images_path

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in the app/assets
# folder are already added.
Rails.application.config.assets.precompile += %w[navbar.js]
