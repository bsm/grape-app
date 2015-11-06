require 'bundler/setup'
require 'pathname'
require 'grape'
require 'active_support/string_inquirer'
require 'active_support/configurable'
require 'active_support/inflector/methods'
require 'activesupport/json_encoder'
require 'hashie-forbidden_attributes'
require 'rack/cors'
require 'rack/ssl-enforcer'

class Grape::App < Grape::API
  include ActiveSupport::Configurable

  class << self

    # Run initializers
    def init!(root = nil)
      @root = Pathname.new(root) if root

      # Require bundle
      Bundler.require :default, env.to_sym

      # Load initializers
      require 'grape/app/initializers/pre'
      require_one 'config', 'environments', env
      require_all 'config', 'initializers'
      require 'grape/app/initializers/post'

      # Load app
      $LOAD_PATH.push @root.join('lib')
      $LOAD_PATH.push @root.join('app')
      $LOAD_PATH.push @root.join('app', 'models')

      require_one 'app', 'models'
      require_one 'app', 'api'
    end

    # @return [Pathname] root path
    def root
      @root ||= Bundler.root.dup
    end

    # @return [ActiveSupport::StringInquirer] env name
    def env
      @env ||= ActiveSupport::StringInquirer.new(ENV['GRAPE_ENV'] || ENV['RACK_ENV'] || 'development')
    end

    def autoload(paths)
      paths.each do |path|
        Object.autoload ActiveSupport::Inflector.classify(path), path
      end
    end

    def middleware
      config = self.config
      @middleware ||= Rack::Builder.new do
        use Rack::SslEnforcer if config.force_ssl
        use Rack::Cors do
          allow do
            origins   *Array.wrap(config.cors_allow_origins)
            resource  '*', headers: :any, methods: [:get, :post, :options, :delete, :put]
          end
        end if config.cors_allow_origins

        run Grape::App
      end
    end

    private

    def require_all(*args)
      args = args + ['**', '*.rb']
      Dir[root.join(*args).to_s].each {|f| require f }
    end

    def require_one(*args)
      path = root.join(*args).to_s
      require path if File.exists?("#{path}.rb")
    end

  end
end

require 'grape/app/helpers'
