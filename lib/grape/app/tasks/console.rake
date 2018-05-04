desc 'Launch console'
task console: :environment do
  ::ARGV.clear

  require 'irb'
  require 'irb/completion'

  IRB.start(Grape::App.root.to_s)
end
