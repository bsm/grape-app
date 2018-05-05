require File.expand_path('config/environment', __dir__)

run Grape::App.middleware
