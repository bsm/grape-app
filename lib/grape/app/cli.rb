require 'grape/app'
require 'thor'

module Grape::App::CLI
  class Builder < Thor::Group
    include Thor::Actions
    argument :name, required: true

    def self.source_root
      File.join(File.dirname(__FILE__), 'templates')
    end

    def copy_templates
      prefix = File.join(self.class.source_root, "")

      Dir[File.join(self.class.source_root, '**', '*')].each do |file|
        next if File.directory?(file)

        file.sub! prefix, ""
        copy_file file, File.join(name, file)
      end
    end

    def init_lib
      empty_directory File.join(name, "lib", name)
    end

  end

  class Runner < Thor
    register Builder, :new, "new NAME", "create a new application"

    desc 'console ENV', 'Launch console'
    def console(env='development')
      ENV['GRAPE_ENV'] = env
      require File.expand_path('config/environment', Dir.pwd)

      require 'irb'
      require 'irb/completion'

      ARGV.clear
      IRB.start
    end
  end
end

Grape::App::CLI::Runner.start
