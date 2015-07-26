Grape::App.configure do |c|
  c.test_specific = true
  c.raise_on_missing_translations = true
  c.cors_allow_origins = ['example.com']
end
