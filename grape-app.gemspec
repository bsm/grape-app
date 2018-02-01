# encoding: utf-8

Gem::Specification.new do |s|
  s.name          = 'grape-app'
  s.version       = '0.5.0'
  s.authors       = ['Black Square Media Ltd']
  s.email         = ['info@blacksquaremedia.com']
  s.summary       = %{Stanalone Grape API apps}
  s.description   = %{}
  s.homepage      = 'https://github.com/bsm/grape-app'
  s.license       = 'MIT'

  s.files         = `git ls-files -z`.split("\x0").reject {|f| f.match(%r{^spec/}) }
  s.test_files    = `git ls-files -z -- spec/*`.split("\x0")
  s.executables   = ['grape-app']
  s.require_paths = ['lib']
  s.required_ruby_version = '>= 2.2'

  s.add_dependency 'grape'
  s.add_dependency 'grape-entity'
  s.add_dependency 'activesupport'
  s.add_dependency 'rack-cors'
  s.add_dependency 'rack-ssl-enforcer'
  s.add_dependency 'thor'

  s.add_development_dependency 'bundler'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'activerecord'
  s.add_development_dependency 'sqlite3'
  s.add_development_dependency 'rack-test'
end

