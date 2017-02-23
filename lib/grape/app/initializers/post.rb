if Grape::App.config.raise_on_missing_translations
  handler = lambda {|exception, *| exception = exception.to_exception if exception.respond_to?(:to_exception); raise exception }
  I18n.exception_handler = handler
end

if defined?(ActiveRecord)
  require 'yaml'
  require 'erb'

  configurations = YAML.load(ERB.new(Grape::App.root.join('config', 'database.yml').read).result) || {}
  if ENV['DATABASE_URL']
    configurations[Grape::App.env.to_s] ||= {}
    configurations[Grape::App.env.to_s]['url'] ||= ENV['DATABASE_URL']
  end

  ActiveRecord::Base.configurations = configurations
  ActiveRecord::Base.default_timezone = :utc
  ActiveRecord::Base.establish_connection(Grape::App.env.to_sym)

  if defined?(ActiveRecord::ConnectionAdapters::ConnectionManagement)
    Grape::App.middleware.use ActiveRecord::ConnectionAdapters::ConnectionManagement
  end
end
