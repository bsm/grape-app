Grape::App.configure do |config|
  # Force SSL, please see https://github.com/tobmatth/rack-ssl-enforcer
  # for configuration options.
  #
  # config.force_ssl = { strict: true }

  # CORS is disabled by default, please see https://github.com/cyu/rack-cors
  # for configuration options.
  #
  # config.cors do
  #   allow do
  #     origins   '*'
  #     resource  '*', headers: :any, methods: [:get, :post, :options]
  #   end
  # end

  # Enable custom middleware:
  #
  # config.middleware do
  #   use Rack::ETag
  #   insert_before Rack::Cors, Rack::ContentLength
  # end

  # Don't raise errors on missing translations
  # config.raise_on_missing_translations = false
end
