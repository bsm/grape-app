class MyLib
  class BadRequest < StandardError
  end

  class Middleware

    def initialize(app)
      @app = app
    end

    def call(env)
      status, headers, body = @app.call(env)
      headers['X-MyApp'] = 'true'
      [status, headers, body]
    end

  end
end
