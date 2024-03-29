require 'bundler/setup'
require 'pathname'
require 'openssl'
require 'grape'
require 'rack/cors'
require 'rack/ssl-enforcer'
require 'zeitwerk'

ENV['RAILS_DISABLE_DEPRECATED_TO_S_CONVERSION'] ||= 'true'
require 'active_support/all'
require 'active_support/string_inquirer'
require 'active_support/configurable'

class Grape::App < Grape::API
  class << self
    # Run initializers
    def init!(root = nil)
      @root = Pathname.new(root) if root

      # Require bundle
      Bundler.require :default, env.to_sym

      # Update load path
      $LOAD_PATH.push self.root.join('lib').to_s

      # Push dirs to loader
      push_dir? self.root.join('app')
      push_dir? self.root.join('app', 'models')

      # Load initializers
      require 'grape/app/initializers/pre'
      require_one 'config', 'environments', env
      require_all 'config', 'initializers'
      require 'grape/app/initializers/post'

      # Setup loader
      loader.setup

      # Load app
      require_one 'app', 'api'
      Zeitwerk::Loader.eager_load_all if Grape::App.config.eager_load
    end

    # @return [Grape::App::Configuration] the configuration
    def config
      @config ||= if respond_to?(:superclass) && superclass.respond_to?(:config)
                    superclass.config.inheritable_copy
                  else
                    Class.new(Grape::App::Configuration).new
                  end
    end

    # Configure the app
    def configure
      yield config
    end

    # @return [Pathname] root path
    def root
      @root ||= Bundler.root.dup
    end

    # @return [ActiveSupport::StringInquirer] env name
    def env
      @env ||= ActiveSupport::StringInquirer.new(ENV.fetch('GRAPE_ENV') { ENV.fetch('RACK_ENV', 'development') })
    end

    # @return [Zeitwerk::Loader] loader
    def loader
      @loader ||= Zeitwerk::Loader.new.tap do |l|
        l.inflector = Grape::App::Inflector.new
      end
    end

    def middleware
      config = self.config
      @middleware ||= Rack::Builder.new do
        use Rack::Cors, &config.cors if config.cors

        if config.force_ssl.is_a?(Hash)
          use Rack::SslEnforcer, **config.force_ssl
        elsif config.force_ssl
          use Rack::SslEnforcer
        end

        config.middleware.each do |block|
          instance_eval(&block)
        end

        use Grape::App::Middleware::ConnectionManagement if defined?(ActiveRecord)

        run Grape::App
      end
    end

    private

    def push_dir?(dir)
      loader.push_dir(dir) if dir.exist?
    end

    def require_all(*args)
      args += ['**', '*.rb']
      Dir[root.join(*args).to_s].sort.each {|f| require f }
    end

    def require_one(*args)
      path = root.join(*args).to_s
      require path if File.exist?("#{path}.rb")
    end
  end
end

require 'grape/app/configuration'
require 'grape/app/helpers'
require 'grape/app/inflector'
require 'grape/app/middleware'
