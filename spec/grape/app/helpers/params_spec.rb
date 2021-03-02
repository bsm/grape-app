require 'spec_helper'

RSpec.describe Grape::App::Helpers::Params do
  include Rack::Test::Methods

  let :app do
    helper = described_class
    Class.new(Grape::API) do
      format :json

      helpers helper

      params do
        optional :title
      end
      post '/articles' do
        attrs = { id: 9, updated_at: Time.at(1515151515).utc }
        attrs.update(declared_params)
        Article.new(attrs)
      end
    end
  end

  it 'limits params' do
    post '/articles', title: 'Today', id: 1234, updated_at: Time.now
    expect(last_response.status).to eq(201)
    expect(JSON.parse(last_response.body)).to eq(
      'created_at' => nil,
      'id'         => 9,
      'title'      => 'Today',
      'updated_at' => '2018-01-05T11:25:15.000Z',
    )
  end
end
