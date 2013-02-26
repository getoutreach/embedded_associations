# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'embedded_associations/version'

Gem::Specification.new do |gem|
  gem.name          = "embedded_associations"
  gem.version       = EmbeddedAssociations::VERSION
  gem.authors       = ["Gordon L. Hempton"]
  gem.email         = ["ghempton@gmail.com"]
  gem.description   = %q{ActiveRecord controller-level support for embedded associations}
  gem.summary       = %q{ActiveRecord controller-level support for embedded associations}
  gem.homepage      = "https://github.com/GroupTalent/embedded_associations"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency "railties", "> 3.0.0"
end
