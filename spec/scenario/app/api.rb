require 'my_lib'

module API
  extend ActiveSupport::Autoload

  autoload :V1
end

# Mount root API to app
Grape::App.mount API::V1
