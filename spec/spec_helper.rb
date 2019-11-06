ENV['RACK_ENV'] ||= 'test'
require 'grape-app'
require 'rack/test'

class Article
  include Virtus.model

  class Scope
    include Enumerable

    def maximum(*)
      map(&:updated_at).max
    end

    def each
      yield Article.new(id: 1, title: 'Welcome', updated_at: Time.at(1515151510).utc)
      yield Article.new(id: 2, title: 'Bye', updated_at: Time.at(1515151520).utc)
    end
  end

  def self.all
    Scope.new
  end

  attribute :id
  attribute :title
  attribute :updated_at

  def to_param
    id.to_s
  end
end

class TestAPI < Grape::API::Instance
  format :json

  helpers Grape::App::Helpers::Caching
  helpers Grape::App::Helpers::Params

  get '/articles' do
    scope = Article.all
    fresh_when(scope, public: true)
    scope.map(&:to_hash)
  end

  get '/articles/:id' do
    article = Article.all.first
    article.to_hash if stale?(article, stale_if_error: 5, extras: { a: 1, b: 2 })
  end

  params do
    requires :title
    optional :fresh
  end
  post '/articles' do
    attrs = { id: 9, updated_at: Time.at(1515151515).utc }
    attrs.update(declared_params)
    Article.new(attrs).to_hash
  end
end
