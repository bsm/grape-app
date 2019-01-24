module API
end

# Mount root API to app
Grape::App.instance_eval do
  mount API::V1
end
