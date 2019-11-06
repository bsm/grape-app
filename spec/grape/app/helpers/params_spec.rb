require 'spec_helper'

RSpec.describe Grape::App::Helpers::Params do
  include Rack::Test::Methods

  let(:app) { TestAPI }

  it 'should limit params' do
    post '/articles', title: 'Today', fresh: true, id: 1234, updated_at: Time.now
    expect(last_response.status).to eq(201)
    expect(JSON.parse(last_response.body)).to eq(
      'id'         => 9,
      'title'      => 'Today',
      'updated_at' => '2018-01-05 11:25:15 UTC',
    )
  end
end
