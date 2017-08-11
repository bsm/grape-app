load 'active_record/railties/databases.rake'

ActiveRecord::Tasks::DatabaseTasks.tap do |config|
  config.db_dir = 'db'
  config.migrations_paths = ['db/migrate']
  config.seed_loader = Class.new do
    def self.load_seed
      load Grape::App.root.join('db', 'seeds.rb').to_s
    end
  end
end

namespace :db do

  Rake::Task['load_config'].clear

  task load_config: :environment do
    ActiveRecord::Tasks::DatabaseTasks.tap do |config|
      config.root   = Grape::App.root
      config.env    = Grape::App.env
      config.database_configuration = ActiveRecord::Base.configurations
    end
  end

  desc "Create a new migration using NAME"
  task migration: :environment do
    abort "No NAME specified. Example usage: `rake db:migration NAME=create_widgets`" unless ENV["NAME"]

    migrations_path = ActiveRecord::Migrator.migrations_paths.first

    name = ENV["NAME"]
    path = File.join(migrations_path, "#{Time.now.utc.strftime('%Y%m%d%H%M%S')}_#{name}.rb")

    FileUtils.mkdir_p(migrations_path)
    File.write path, <<-MIGRATION.strip_heredoc
      class #{name.camelize} < ActiveRecord::Migration
        def change
        end
      end
    MIGRATION
    puts path
  end

  namespace :test do
    desc "Prepare test DB"
    task :prepare
  end

end
