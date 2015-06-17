# Set default time-zone
Time.zone = 'UTC'

# Configure big-decimal encoding
ActiveSupport.encode_big_decimal_as_string = false

# Add default I18n paths and set default locale
I18n.load_path += Dir[Grape::App.root.join('config', 'locales', '*.{rb,yml}').to_s]
I18n.default_locale = :en
