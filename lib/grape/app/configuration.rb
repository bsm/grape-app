class Grape::App::Configuration < ActiveSupport::InheritableOptions
  def middleware(&block)
    self[:middleware] ||= []
    self[:middleware].push(block) if block
    super
  end

  def cors(&block)
    self.cors = block if block
    super
  end

  def cors_allow_origins=(value)
    warn "[DEPRECATION] setting `config.cors_allow_origins` is deprecated. Please use `config.cors` with a block instead. [#{caller(1..1).first}]"

    value = Array.wrap(value)
    cors do
      allow do
        origins *value # rubocop:disable Lint/AmbiguousOperator
        resource '*', headers: :any, methods: %i[get post options delete put]
      end
    end
  end
end
