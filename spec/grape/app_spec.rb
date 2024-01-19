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
    expect(I18n.exception_handler).to be_a(I18n::ExceptionHandler)
  end

  it 'configures ActiveSupport' do
    expect(ActiveSupport.to_time_preserves_timezone).to be(true)
    expect(ActiveSupport.utc_to_local_returns_utc_offset_times).to be(true)
    expect(ActiveSupport::Digest.hash_digest_class).to be(OpenSSL::Digest::SHA256)
    expect(ActiveSupport::MessageEncryptor.use_authenticated_message_encryption).to be(true)
    if ActiveSupport::VERSION::MAJOR >= 7
      expect(ActiveSupport::KeyGenerator.hash_digest_class).to be(OpenSSL::Digest::SHA256)
      expect(ActiveSupport::IsolatedExecutionState.isolation_level).to be(:thread)
      # expect(Digest::UUID.use_rfc4122_namespaced_uuids).to be(true)
    end
  end

  it 'configures ActiveRecord' do
    if ActiveRecord::VERSION::MAJOR >= 7
      expect(ActiveRecord.default_timezone).to be(:utc)
      expect(ActiveRecord.verify_foreign_keys_for_fixtures).to be(true)
      expect(ActiveRecord::Base.partial_inserts).to be(false)
      expect(ActiveRecord::Base.automatic_scope_inversing).to be(true)
    end
    expect(ActiveRecord::Base.belongs_to_required_by_default).to be(true)
    expect(ActiveRecord::Base.cache_versioning).to be(true)
    expect(ActiveRecord::Base.collection_cache_versioning).to be(true)
    expect(ActiveRecord::Base.has_many_inversing).to be(true)
  end

  it 'configures ActiveJob' do
    expect(ActiveJob::Base.retry_jitter).to eq(0.15)
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
    expect(subject.middleware.send(:instance_variable_get, :@use).size).to eq(3)
    expect(subject.middleware.send(:instance_variable_get, :@run)).to be(subject)
  end

  it 'applies middleware' do
    header 'Origin', 'test.host'
    get '/v1/ok'
    expect(last_response).to be_ok
    expect(last_response.body).to eq(%({"status":"OK"}))
    expect(last_response.headers).to include(
      'access-control-allow-origin' => '*',
      'X-MyApp'                     => 'true',
    )

    header 'Origin', 'test.host'
    get '/v1/failing'
    expect(last_response).to be_bad_request
    expect(last_response.body).to eq(%({"error":"bad request"}))
    expect(last_response.headers).to include(
      'access-control-allow-origin' => '*',
      'X-MyApp'                     => 'true',
    )
  end
end
