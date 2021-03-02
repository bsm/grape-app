require 'spec_helper'

RSpec.describe Grape::App::Middleware::ConnectionManagement do
  include Rack::Test::Methods

  let :app do
    failing = ->(_) { raise(ActiveRecord::StatementInvalid) }
    middleware = described_class
    Rack::Builder.new do
      use middleware
      run failing
    end
  end

  it 'clears active connections' do
    ActiveRecord::Base.connection
    expect(ActiveRecord::Base.connection_handler).to be_active_connections

    expect { get '/' }.to raise_error(ActiveRecord::StatementInvalid)
    expect(ActiveRecord::Base.connection_handler).not_to be_active_connections
  end
end
