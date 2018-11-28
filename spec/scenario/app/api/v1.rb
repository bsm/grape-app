class API::V1 < Grape::API
  version 'v1'
  format  :json

  rescue_from MyLib::BadRequest do |e|
    error!({ error: e }, 400)
  end

  get '/ok' do
    { status: 'OK' }
  end

  get '/failing' do
    raise MyLib::BadRequest, 'bad request'
  end

end
