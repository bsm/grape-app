require 'spec_helper'

RSpec.describe Grape::App::Helpers::Caching do
  include Rack::Test::Methods

  let :app do
    helper = described_class
    Class.new(Grape::API) do
      format :json

      helpers helper

      get '/articles' do
        scope = Article.order(:id)
        opts  = params[:public] ? { public: params[:public] } : {}
        fresh_when(scope, **opts)
        scope.to_a
      end

      get '/articles/never_updated' do
        article = Article.first
        article.updated_at = nil

        fresh_when(article, last_modified_field: :created_at)
      end

      get '/articles/:id' do
        article = Article.first
        article if stale?(article, stale_if_error: 5, extras: { a: 1, b: 2 })
      end
    end
  end
  let(:created_at) { Time.at(1515151500).utc }

  before do
    Article.create! title: 'Welcome', created_at: created_at, updated_at: created_at + 10
    Article.create! title: 'Bye', created_at: created_at, updated_at: created_at + 20
  end

  it 'handles fresh-when' do
    get '/articles'
    expect(last_response.status).to eq(200)
    expect(last_response.headers).to include(
      'Content-Type'  => 'application/json',
      'ETag'          => 'a5f6c4b024510c9835d8d70cbd3ed00c',
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

  it 'handles fresh_when for records that were never updated' do
    get '/articles/never_updated'
    expect(last_response.status).to eq(200)
    expect(last_response.headers).to include(
      'Last-Modified' => 'Fri, 05 Jan 2018 11:25:00 GMT',
    )
  end

  it 'supports cache-control' do
    get '/articles?public=true'
    expect(last_response.status).to eq(200)
    expect(last_response.headers).to include(
      'Cache-Control' => 'public',
    )
  end

  it 'handles stale? (with cache-control)' do
    get '/articles/1'
    expect(last_response.status).to eq(200)
    expect(last_response.headers).to include(
      'Cache-Control' => 'private, stale-if-error=5, a=1, b=2',
      'Content-Type'  => 'application/json',
      'ETag'          => '0154407bafc97186a494a05e0652ff61',
      'Last-Modified' => 'Fri, 05 Jan 2018 11:25:10 GMT',
    )
    expect(JSON.parse(last_response.body)).to eq(
      'id'         => 1,
      'title'      => 'Welcome',
      'updated_at' => '2018-01-05T11:25:10.000Z',
      'created_at' => '2018-01-05T11:25:00.000Z',
    )

    get '/articles/1', {}, 'HTTP_IF_NONE_MATCH' => last_response.headers['ETag']
    expect(last_response.status).to eq(304)
    expect(last_response.headers).to include(
      'Cache-Control' => 'private, stale-if-error=5, a=1, b=2',
      'ETag'          => '0154407bafc97186a494a05e0652ff61',
      'Last-Modified' => 'Fri, 05 Jan 2018 11:25:10 GMT',
    )
  end
end
