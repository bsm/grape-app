class API::V1 < Grape::API
  version 'v1'
  prefix  'api'
  format  :json

  # Custom rescues:
  #
  # rescue_from ActiveRecord::RecordNotFound do |e|
  #   error_response message: e.message, status: 404
  # end

  # Mount components:
  #
  # mount API::Posts
end
