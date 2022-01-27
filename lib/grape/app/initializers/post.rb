if Grape::App.config.raise_on_missing_translations
  handler = ->(exception, *) { exception = exception.to_exception if exception.respond_to?(:to_exception); raise exception }
  I18n.exception_handler = handler
end

if defined?(ActiveRecord)
  require 'yaml'
  require 'erb'

  configurations = YAML.safe_load(ERB.new(Grape::App.root.join('config', 'database.yml').read).result) || {}
  if ENV['DATABASE_URL']
    configurations[Grape::App.env.to_s] ||= {}
    configurations[Grape::App.env.to_s]['url'] ||= ENV['DATABASE_URL']
  end

  if ActiveRecord.respond_to?(:default_timezone=)
    ActiveRecord.default_timezone = :utc
  else
    ActiveRecord::Base.default_timezone = :utc
  end
  ActiveRecord::Base.configurations = configurations
  ActiveRecord::Base.establish_connection(Grape::App.env.to_sym)

  Grape::App.middleware.use ActiveRecord::ConnectionAdapters::ConnectionManagement if defined?(ActiveRecord::ConnectionAdapters::ConnectionManagement)
end
