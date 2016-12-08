# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'chess_rules/version'

Gem::Specification.new do |spec|
  spec.name          = "chess_rules"
  spec.version       = ChessRules::VERSION
  spec.authors       = ["David Ngo"]
  spec.email         = ["davngo@gmail.com"]
  spec.summary       = "rules for chess"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(spec)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'activemodel'

  spec.add_development_dependency "rspec"
  spec.add_development_dependency "byebug"
end
