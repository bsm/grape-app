require 'my_lib'

Grape::App.configure do |c|
  c.test_specific = true
  c.raise_on_missing_translations = true
  c.cors do
    allow do
      origins '*'
      resource '*', headers: :any, methods: %i[get post options]
    end
  end
  c.middleware do
    use MyLib::Middleware
  end
end
