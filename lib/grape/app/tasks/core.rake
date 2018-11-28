task :environment do
  require Bundler.root.join('config', 'environment').to_s
end

desc 'Launch console'
task console: :environment do
  ::ARGV.clear

  require 'irb'
  require 'irb/completion'

  IRB.start(Grape::App.root.to_s)
end

desc 'List all routes'
task routes: :environment do
  Grape::App.routes.each do |route|
    method = route.request_method.ljust(7)
    path   = route.path.sub(':version', route.version.to_s)
    puts "  #{method} #{path}"
  end
end
