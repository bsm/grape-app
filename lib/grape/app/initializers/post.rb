if Grape::App.config.raise_on_missing_translations
  handler = lambda {|exception, *| exception = exception.to_exception if exception.respond_to?(:to_exception); raise exception }
  I18n.exception_handler = handler
end

if defined?(ActiveRecord)
  require 'yaml'

  configurations = YAML.load(Grape::App.root.join('config', 'database.yml').read)
  configurations[Grape::App.env.to_s]['url'] = ENV['DATABASE_URL'] if ENV['DATABASE_URL']

  ActiveRecord::Base.configurations = configurations
  ActiveRecord::Base.default_timezone = :utc
  ActiveRecord::Base.establish_connection(Grape::App.env.to_sym)

  Grape::App.middleware.use ActiveRecord::ConnectionAdapters::ConnectionManagement
end
