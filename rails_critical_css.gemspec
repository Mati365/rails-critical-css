lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'rails_critical_css/version'

Gem::Specification.new do |s|
  s.name = 'rails_critical_css'
  s.version = RailsCriticalCss::VERSION
  s.platform = Gem::Platform::RUBY
  s.summary = 'Critical CSS rails generator'
  s.authors = ['Mateusz Bagiński']

  s.license = 'MIT'
  s.email = 'cziken58@gmail.com'
  s.homepage = 'https://github.com/Mati365/rails-critical-css'
  s.files = `git ls-files`.split($/)

  s.require_paths = ['lib']
  s.required_ruby_version = '>= 2.4.0'
  s.extensions = ['ext/npm/extconf.rb']
end
