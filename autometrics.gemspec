lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'autometrics/version'

Gem::Specification.new do |spec|
  spec.name = 'autometrics'
  spec.version = Autometrics::VERSION
  spec.authors = ['Brett Beutell']
  spec.email = ['brett@fiberplane.com']

  spec.summary =
    'Ruby implmentation of autometrics library'
  spec.description =
    'Add developer-friendly observability to your Ruby code with minimal setup'
  spec.homepage = 'https://github.com/autometrics-dev/autometrics-ruby'
  spec.license = 'MIT'

  spec.files =
    `git ls-files -z`.split("\x0").reject do |f|
      f.match(%r{^(assets|test|spec|features)/})
    end
  # TODO - figure out what bindir does
  # spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 2.3'
  # spec.add_development_dependency 'rake', '~> 12.3.3'
  # spec.add_development_dependency 'rspec', '~> 3.0'

  # TODO - pin version
  spec.add_dependency 'prometheus-client'
end
