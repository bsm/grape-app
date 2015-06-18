ENV['RACK_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)

RSpec.configure do |config|

  # DatabaseCleaner
  config.before :suite do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with :truncation
  end
  config.around :each do |example|
    DatabaseCleaner.cleaning { example.run }
  end

  # FactoryGirl
  config.include FactoryGirl::Syntax::Methods
  config.before :suite do
    FactoryGirl.find_definitions
  end

end

# Test with Airborne
Airborne.configure do |config|
  config.rack_app = Grape::App
end
