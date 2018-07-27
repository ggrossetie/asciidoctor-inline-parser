require File.expand_path('../lib/asciidoctor/inline_parser/version', __FILE__)

Gem::Specification.new do |s|
  s.name     = 'asciidoctor-templates-compiler'
  s.version  = Asciidoctor::InlineParser::VERSION
  s.author   = 'Guillaume Grossetie'
  s.email    = 'ggrossetie@yuzutech.fr'
  s.homepage = 'https://github.com/mogztter/asciidoctor-inline-parser'
  s.license  = 'MIT'

  s.summary  = 'An inline parser for Asciidoctor'

  s.files    = Dir['lib/**/*', '*.gemspec', 'LICENSE*', 'README*']
  s.executables = Dir['bin/*'].map { |f| File.basename(f) }

  s.required_ruby_version = '>= 2.1'

  s.add_runtime_dependency 'asciidoctor', '~> 1.5'
  s.add_runtime_dependency 'treetop', '~> 1.6.10'

  s.add_development_dependency 'rake', '~> 12.0'
  s.add_development_dependency 'minitest', '~> 5.3.0'
  s.add_development_dependency 'simplecov', '~> 0.14'
end
