require 'spec_helper'

RSpec.describe Grape::App::Helpers::Caching do
  include Rack::Test::Methods

  let(:app) { TestAPI }

  it 'should handle fresh-when' do
    get '/articles'
    expect(last_response.status).to eq(200)
    expect(last_response.headers).to include(
      'Content-Type'  => 'application/json',
      'ETag'          => '975ca8804565c1a569450d61090b2743',
      'Last-Modified' => 'Fri, 05 Jan 2018 11:25:20 GMT',
    )
    expect(JSON.parse(last_response.body).size).to eq(2)

    get '/articles', {}, 'HTTP_IF_NONE_MATCH' => last_response.headers['ETag']
    expect(last_response.status).to eq(304)
    get '/articles', {}, 'HTTP_IF_MODIFIED_SINCE' => 'Fri, 05 Jan 2018 11:25:20 GMT'
    expect(last_response.status).to eq(304)
    get '/articles', {}, 'HTTP_IF_NONE_MATCH' => last_response.headers['ETag'], 'HTTP_IF_MODIFIED_SINCE' => 'Fri, 05 Jan 2018 11:25:21 GMT'
    expect(last_response.status).to eq(304)

    get '/articles', {}, 'HTTP_IF_MODIFIED_SINCE' => 'Fri, 05 Jan 2018 11:25:19 GMT'
    expect(last_response.status).to eq(200)
    get '/articles', {}, 'HTTP_IF_MODIFIED_SINCE' => 'Fri, 05 Jan 2018 11:25:19 GMT', 'HTTP_IF_NONE_MATCH' => last_response.headers['ETag']
    expect(last_response.status).to eq(200)
    get '/articles', {}, 'HTTP_IF_MODIFIED_SINCE' => 'Fri, 05 Jan 2018 11:25:20 GMT', 'HTTP_IF_NONE_MATCH' => 'other'
    expect(last_response.status).to eq(200)
  end

  it 'should support cache-control' do
    get '/articles?public=true'
    expect(last_response.status).to eq(200)
    expect(last_response.headers).to include(
      'Cache-Control' => 'public',
    )
  end

  it 'should handle stale? (with cache-control)' do
    get '/articles/1'
    expect(last_response.status).to eq(200)
    expect(last_response.headers).to include(
      'Cache-Control' => 'private, stale-if-error=5, a=1, b=2',
      'Content-Type'  => 'application/json',
      'ETag'          => 'c4ca4238a0b923820dcc509a6f75849b',
      'Last-Modified' => 'Fri, 05 Jan 2018 11:25:10 GMT',
    )
    expect(JSON.parse(last_response.body)).to eq(
      'id'         => 1,
      'title'      => 'Welcome',
      'updated_at' => '2018-01-05 11:25:10 UTC',
    )

    get '/articles/1', {}, 'HTTP_IF_NONE_MATCH' => last_response.headers['ETag']
    expect(last_response.status).to eq(304)
    expect(last_response.headers).to include(
      'Cache-Control' => 'private, stale-if-error=5, a=1, b=2',
      'ETag'          => 'c4ca4238a0b923820dcc509a6f75849b',
      'Last-Modified' => 'Fri, 05 Jan 2018 11:25:10 GMT',
    )
  end
end
