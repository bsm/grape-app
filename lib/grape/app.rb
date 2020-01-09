require 'bundler/setup'
require 'pathname'
require 'grape'
require 'active_support/string_inquirer'
require 'active_support/configurable'
require 'active_support/core_ext/time/zones'
require 'rack/cors'
require 'rack/ssl-enforcer'
require 'zeitwerk'

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
      @env ||= ActiveSupport::StringInquirer.new(ENV['GRAPE_ENV'] || ENV['RACK_ENV'] || 'development')
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
        use Rack::SslEnforcer if config.force_ssl
        config.middleware.each do |block|
          instance_eval(&block)
        end

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
