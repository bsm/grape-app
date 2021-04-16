class Grape::App::Middleware::ConnectionManagement
  def initialize(app)
    @app = app
  end

  def call(env)
    @app.call(env)
  rescue ::ActiveRecord::StatementInvalid
    ::ActiveRecord::Base.clear_active_connections!
    raise
  end
end
