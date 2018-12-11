require 'bundler/setup'
require 'pathname'
require 'grape'
require 'active_support/string_inquirer'
require 'active_support/configurable'
require 'active_support/inflector/methods'
require 'active_support/core_ext/time/zones'
require 'rack/cors'
require 'rack/ssl-enforcer'

class Grape::App < Grape::API::Instance
  class << self

    # Run initializers
    def init!(root=nil)
      @root = Pathname.new(root) if root

      # Require bundle
      Bundler.require :default, env.to_sym

      # Update load path
      $LOAD_PATH.push self.root.join('lib').to_s
      $LOAD_PATH.push self.root.join('app').to_s
      $LOAD_PATH.push self.root.join('app', 'models').to_s

      # Load initializers
      require 'grape/app/initializers/pre'
      require_one 'config', 'environments', env
      require_all 'config', 'initializers'
      require 'grape/app/initializers/post'

      # Load app
      require_one 'app', 'models'
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

    def autoload(paths)
      paths.each do |path|
        Object.autoload ActiveSupport::Inflector.classify(path), path
      end
    end

    def middleware
      config = self.config
      @middleware ||= Rack::Builder.new do
        use Rack::Cors, &config.cors if config.cors
        use Rack::SslEnforcer if config.force_ssl
        instance_eval(&config.middleware) if config.middleware

        run Grape::App
      end
    end

    private

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
