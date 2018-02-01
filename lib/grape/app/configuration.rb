class Grape::App::Configuration < ActiveSupport::InheritableOptions

  def middleware(&block)
    self.middleware = block if block
    super
  end

  def cors(&block)
    self.cors = block if block
    super
  end

  def cors_allow_origins=(value)
    warn "[DEPRECATION] setting `config.cors_allow_origins` is deprecated. Please use `config.cors` with a block instead. [#{caller[0]}]"

    value = Array.wrap(value)
    self.cors do
      allow do
        origins   *value
        resource  '*', headers: :any, methods: [:get, :post, :options, :delete, :put]
      end
    end
  end

end
