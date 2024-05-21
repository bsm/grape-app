Gem::Specification.new do |s|
  s.name          = 'grape-app'
  s.version       = '0.11.4'
  s.authors       = ['Black Square Media Ltd']
  s.email         = ['info@blacksquaremedia.com']
  s.summary       = %(Standalone Grape API apps)
  s.description   = %()
  s.homepage      = 'https://github.com/bsm/grape-app'
  s.license       = 'MIT'

  s.files         = `git ls-files -z`.split("\x0").reject {|f| f.match(%r{^spec/}) }
  s.executables   = ['grape-app']
  s.require_paths = ['lib']
  s.required_ruby_version = '>= 2.7'

  s.add_dependency 'activesupport'
  s.add_dependency 'grape', '>= 1.7'
  s.add_dependency 'grape-entity'
  s.add_dependency 'openssl'
  s.add_dependency 'rack-cors', '>= 1.1'
  s.add_dependency 'rack-ssl-enforcer'
  s.add_dependency 'thor'
  s.add_dependency 'zeitwerk', '>= 2.6'

  s.metadata['rubygems_mfa_required'] = 'true'
end
