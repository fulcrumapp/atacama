# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'atacama/version'

Gem::Specification.new do |spec|
  spec.name          = 'atacama'
  spec.version       = Atacama::VERSION
  spec.authors       = ['Tyler Johnston']
  spec.email         = ['tyler@spatialnetworks.com']
  spec.license       = 'MIT'
  spec.summary       = 'DRY Service Objects'
  spec.description   = 'Service objects using composable contracts'
  spec.homepage      = 'https://github.com/fulcrumapp/atacama'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'dry-types'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'minitest'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'pry'
end
