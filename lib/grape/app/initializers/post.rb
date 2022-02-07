if defined?(ActiveRecord)
  require 'yaml'
  require 'erb'

  configurations = YAML.safe_load(ERB.new(Grape::App.root.join('config', 'database.yml').read).result) || {}
  if ENV['DATABASE_URL']
    configurations[Grape::App.env.to_s] ||= {}
    configurations[Grape::App.env.to_s]['url'] ||= ENV['DATABASE_URL']
  end
  ActiveRecord::Base.configurations = configurations
  ActiveRecord::Base.establish_connection(Grape::App.env.to_sym)

  Grape::App.middleware.use ActiveRecord::ConnectionAdapters::ConnectionManagement if defined?(ActiveRecord::ConnectionAdapters::ConnectionManagement)
end
