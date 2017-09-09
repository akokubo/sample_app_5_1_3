require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module SampleApp514
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    
    # Include the authenticity token in remote forms.
    # Ajaxに対応しないブラウザでも動作するように
    # リモートフォームに認証トークンを埋め込む
    config.action_view.embed_authenticity_token_in_remote_forms = true

    config.i18n.available_locales = [:ja, :en]
    config.i18n.enforce_available_locales = true
    config.i18n.default_locale = :en
  end
end
