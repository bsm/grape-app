require 'spec_helper'

RSpec.describe Grape::App do
  include Rack::Test::Methods

  subject { described_class }

  before  { subject.init! File.expand_path('../scenario', __dir__) }

  def app
    subject.middleware
  end

  it 'has an env' do
    expect(subject.env).to be_instance_of(ActiveSupport::StringInquirer)
    expect(subject.env).to eq('test')
  end

  it 'has an root' do
    expect(subject.root).to be_instance_of(Pathname)
  end

  it 'is an API instance' do
    expect(subject).to be < Grape::API
  end

  it 'inits with default time zone' do
    expect(Time.zone.name).to eq('UTC')
    expect(Thread.new { Time.zone }.value.name).to eq('UTC')
  end

  it 'configures i18n' do
    expect(I18n.load_path).to include(subject.root.join('config', 'locales', 'en.yml').to_s)
    expect(I18n.default_locale).to eq(:en)
    expect(I18n.exception_handler).to be_instance_of(Proc)
  end

  it 'reads env specific initializers' do
    expect(subject.config).to include(
      :test_specific,
      :raise_on_missing_translations,
      :cors,
      :middleware,
    )
  end

  it 'prepares middleware' do
    expect(subject.middleware).to be_instance_of(Rack::Builder)
    expect(subject.middleware.send(:instance_variable_get, :@use).size).to eq(2)
    expect(subject.middleware.send(:instance_variable_get, :@run)).to be(subject)
  end

  it 'applies middleware' do
    header 'Origin', 'test.host'
    get '/v1/ok'
    expect(last_response).to be_ok
    expect(last_response.body).to eq(%({"status":"OK"}))
    expect(last_response.headers).to include(
      'Access-Control-Allow-Origin' => '*',
      'X-MyApp'                     => 'true',
    )

    header 'Origin', 'test.host'
    get '/v1/failing'
    expect(last_response).to be_bad_request
    expect(last_response.body).to eq(%({"error":"bad request"}))
    expect(last_response.headers).to include(
      'Access-Control-Allow-Origin' => '*',
      'X-MyApp'                     => 'true',
    )
  end
end
