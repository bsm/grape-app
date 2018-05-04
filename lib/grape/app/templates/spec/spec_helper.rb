ENV['RACK_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)

RSpec.configure do |config|

  # ActiveRecord::Migration
  config.before :suite do
    ActiveRecord::Migration.maintain_test_schema!
  end if defined?(ActiveRecord)

  # DatabaseCleaner
  config.before :suite do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with :truncation
  end
  config.around :each do |example|
    DatabaseCleaner.cleaning { example.run }
  end

  # FactoryBot
  config.include FactoryBot::Syntax::Methods
  config.before :suite do
    FactoryBot.find_definitions
  end

end

# Test with Airborne
Airborne.configure do |config|
  config.rack_app = Grape::App
end
