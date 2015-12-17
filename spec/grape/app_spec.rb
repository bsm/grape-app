require 'spec_helper'

RSpec.describe Grape::App do

  subject { described_class }
  before  { subject.init! File.expand_path('../../scenario', __FILE__) }

  it 'should have an env' do
    expect(subject.env).to be_instance_of(ActiveSupport::StringInquirer)
    expect(subject.env).to eq("test")
  end

  it 'should have an root' do
    expect(subject.root).to be_instance_of(Pathname)
  end

  it 'should be an API' do
    expect(subject).to be < Grape::API
  end

  it 'should init with default time zone' do
    expect(Time.zone.name).to eq("UTC")
    expect(Thread.new { Time.zone }.value.name).to eq("UTC")
  end

  it 'should configure i18n' do
    expect(I18n.load_path).to include(subject.root.join("config", "locales", "en.yml").to_s)
    expect(I18n.default_locale).to eq(:en)
    expect(I18n.exception_handler).to be_instance_of(Proc)
  end

  it 'should read env specific initializers' do
    expect(subject.config).to eq(
      test_specific: true,
      raise_on_missing_translations: true,
      cors_allow_origins: ["example.com"],
    )
  end

  it 'should prepare middleware' do
    expect(subject.middleware).to be_instance_of(Rack::Builder)
    expect(subject.middleware.send(:instance_variable_get, :@use).size).to eq(1)
    expect(subject.middleware.send(:instance_variable_get, :@run)).to eq(subject)
  end

end
